#!/usr/bin/env python3
"""Opt-in macOS preferences and adaptive Terminal profile restoration."""
import argparse
import datetime
from pathlib import Path
import plistlib
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]

# Store only the preferences selected for this setup, not whole machine profiles.
# None removes an override so macOS supplies its normal default behavior.
PREFERENCES = {
    "wallpaper": {
        "com.apple.WindowManager": {"EnableStandardClickToShowDesktop": False},
    },
    "finder": {
        # Show hidden files/folders and always display filename extensions.
        "com.apple.finder": {"AppleShowAllFiles": True},
        "NSGlobalDomain": {"AppleShowAllExtensions": True},
    },
    "dock": {
        "com.apple.dock": {
            # Reveal immediately, while retaining the normal slide animation.
            "autohide": True,
            "autohide-delay": 0.0,
            "autohide-time-modifier": None,
            # Hide recent/suggested apps and preserve the current icon sizes.
            "show-recents": False,
            "magnification": True,
            "tilesize": 52.0,
            "largesize": 71.0,
            # Keep manual resizing available.
            "size-immutable": False,
        },
    },
    "windows": {
        # Enable native edge/top tiling without gaps around tiled windows.
        "com.apple.WindowManager": {
            "EnableTilingByEdgeDrag": True,
            "EnableTopTilingByEdgeDrag": True,
            "EnableTiledWindowMargins": False,
        },
    },
}


def export(domain):
    result = subprocess.run(["defaults", "export", domain, "-"], capture_output=True)
    if result.returncode:
        raise RuntimeError(f"Could not read {domain}: {result.stderr.decode().strip()}")
    return plistlib.loads(result.stdout)


def backup(domain, preferences):
    stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
    path = Path.home() / ".local/state/dotfiles/backups" / stamp / (domain + ".plist")
    path.parent.mkdir(parents=True)
    path.write_bytes(plistlib.dumps(preferences))
    print(f"Preference backup: {path}")


def apply_preferences(domain, desired, dry_run=False):
    for key, value in desired.items():
        if value is None:
            print(f"Reset {domain} {key} to the macOS default")
        else:
            print(f"Set {domain} {key} = {value}")
    if dry_run:
        return
    preferences = export(domain)
    changes = {key: value for key, value in desired.items()
               if (key in preferences if value is None else preferences.get(key) != value)}
    if not changes:
        print(f"{domain} already configured")
        return
    backup(domain, preferences)
    for key, value in changes.items():
        # Write individual keys so unrelated preferences and pinned apps survive.
        if value is None:
            command = ["defaults", "delete", domain, key]
        elif isinstance(value, bool):
            command = ["defaults", "write", domain, key, "-bool", str(value).lower()]
        else:
            command = ["defaults", "write", domain, key, "-float", str(value)]
        subprocess.run(command, check=True)
    actual = export(domain)
    for key, value in desired.items():
        if (key in actual if value is None else actual.get(key) != value):
            raise RuntimeError(f"Preference verification failed: {domain} {key}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--wallpaper", action="store_true", help="Disable standard wallpaper clicks hiding windows")
    parser.add_argument("--finder", action="store_true", help="Show hidden files/folders and filename extensions")
    parser.add_argument("--dock", action="store_true", help="Restore auto-hide, immediate reveal, magnification and icon sizes")
    parser.add_argument("--windows", action="store_true", help="Enable native edge/top window tiling without margins")
    parser.add_argument("--terminal", action="store_true", help="Install the Dotfiles profile and make it default/startup")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    if not (any(getattr(args, group) for group in PREFERENCES) or args.terminal):
        parser.error("Choose --wallpaper, --finder, --dock, --windows and/or --terminal")
    if sys.platform != "darwin":
        parser.error("macOS only")
    if args.terminal and not args.dry_run:
        # Terminal may overwrite preferences on exit. Never close a user's sessions.
        running = subprocess.run(["pgrep", "-x", "Terminal"], capture_output=True)
        if running.returncode == 0:
            raise RuntimeError("Quit Apple Terminal first, then run from another terminal or your agent's shell")
    # Combine groups sharing a domain so each backup contains its original state.
    selected = {}
    for group, domains in PREFERENCES.items():
        if getattr(args, group):
            for domain, preferences in domains.items():
                selected.setdefault(domain, {}).update(preferences)
    for domain, preferences in selected.items():
        apply_preferences(domain, preferences, args.dry_run)
    if args.finder or args.dock or args.windows:
        print("After applying, log out and back in for all changes to take effect. See README for Finder/Dock refresh commands.")
    if args.terminal:
        print("Install adaptive Dotfiles Terminal profile; set default and startup profile to Dotfiles")
        if not args.dry_run:
            domain = "com.apple.Terminal"
            preferences = export(domain)
            profile = plistlib.loads((ROOT / "macos/Dotfiles.terminal").read_bytes())
            name = profile["name"]
            current = preferences.get("Window Settings", {}).get(name)
            if current == profile and preferences.get("Default Window Settings") == name and preferences.get("Startup Window Settings") == name:
                print("Terminal profile already configured")
                return
            backup(domain, preferences)
            preferences.setdefault("Window Settings", {})[name] = profile
            preferences["Default Window Settings"] = name
            preferences["Startup Window Settings"] = name
            subprocess.run(["defaults", "import", domain, "-"], input=plistlib.dumps(preferences), check=True)
            if export(domain).get("Default Window Settings") != name:
                raise RuntimeError("Terminal profile verification failed")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError, OSError) as error:
        print(f"Preference setup failed: {error}", file=sys.stderr)
        sys.exit(1)
