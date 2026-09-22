#!/usr/bin/env python3
"""Opt-in macOS preferences and adaptive Terminal profile restoration."""
import argparse
import datetime
from pathlib import Path
import plistlib
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--wallpaper", action="store_true", help="Disable standard wallpaper clicks hiding windows")
    parser.add_argument("--terminal", action="store_true", help="Install the Dotfiles profile and make it default/startup")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    if not (args.wallpaper or args.terminal):
        parser.error("Choose --wallpaper and/or --terminal")
    if sys.platform != "darwin":
        parser.error("macOS only")
    if args.terminal and not args.dry_run:
        # Terminal may overwrite preferences on exit. Never close a user's sessions.
        running = subprocess.run(["pgrep", "-x", "Terminal"], capture_output=True)
        if running.returncode == 0:
            raise RuntimeError("Quit Apple Terminal first, then run from another terminal or your agent's shell")
    if args.wallpaper:
        print("Set com.apple.WindowManager EnableStandardClickToShowDesktop = false")
        if not args.dry_run:
            domain = "com.apple.WindowManager"
            preferences = export(domain)
            if preferences.get("EnableStandardClickToShowDesktop") is not False:
                backup(domain, preferences)
                subprocess.run(["defaults", "write", domain, "EnableStandardClickToShowDesktop", "-bool", "false"], check=True)
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
