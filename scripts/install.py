#!/usr/bin/env python3
"""Install dependencies, pinned plugins and backed-up configuration links."""
import argparse
import datetime
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
FILES = (".zshrc", ".vimrc", ".hushlogin")


def run(*args, **kwargs):
    return subprocess.run([str(a) for a in args], check=True, **kwargs)


def output(*args):
    return subprocess.check_output([str(a) for a in args], text=True).strip()


def brew_path():
    candidates = (shutil.which("brew"), "/opt/homebrew/bin/brew", "/usr/local/bin/brew")
    return next((p for p in candidates if p and os.access(p, os.X_OK)), None)


class Installer:
    def __init__(self, target):
        self.target = target.resolve()
        stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
        self.backups = self.target / ".local/state/dotfiles/backups" / stamp
        self.records = []

    def backup(self, path):
        if not os.path.lexists(path):
            return
        relative = path.relative_to(self.target)
        saved = self.backups / relative
        saved.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(path), str(saved))
        self.records.append({"original": str(path), "backup": str(saved)})
        (self.backups / "manifest.json").write_text(json.dumps(self.records, indent=2) + "\n")
        print(f"Backed up {path} to {saved}")

    def link(self, name):
        source, destination = ROOT / name, self.target / name
        if destination.is_symlink() and destination.resolve() == source:
            print(f"Already linked: {name}")
            return
        self.backup(destination)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.symlink_to(source)
        print(f"Linked {destination}")

    def plugin(self, plugin):
        destination = self.target / plugin["path"]
        parent = destination.parent.resolve()
        if parent != self.target and self.target not in parent.parents:
            raise RuntimeError(f"Refusing plugin installation through a directory symlink outside {self.target}: {destination}")
        if destination.is_dir() and (destination / ".git").is_dir():
            current = output("git", "-C", destination, "rev-parse", "HEAD")
            origin = output("git", "-C", destination, "remote", "get-url", "origin")
            dirty = output("git", "-C", destination, "status", "--porcelain", "--untracked-files=no")
            if current == plugin["commit"] and origin == plugin["url"] and not dirty:
                print(f"Already installed: {plugin['name']} @ {current[:12]}")
                return
        # Download fully before moving an existing installation out of the way.
        destination.parent.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(prefix=".dotfiles-", dir=destination.parent) as temp:
            checkout = Path(temp) / "plugin"
            run("git", "init", "-q", checkout)
            run("git", "-C", checkout, "remote", "add", "origin", plugin["url"])
            run("git", "-C", checkout, "fetch", "-q", "--depth=1", "origin", plugin["commit"])
            run("git", "-C", checkout, "checkout", "-q", "--detach", "FETCH_HEAD")
            if output("git", "-C", checkout, "rev-parse", "HEAD") != plugin["commit"]:
                raise RuntimeError(f"Unexpected revision for {plugin['name']}")
            self.backup(destination)
            shutil.move(str(checkout), str(destination))
        print(f"Installed {plugin['name']} @ {plugin['commit'][:12]}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="Print the plan without changing anything")
    parser.add_argument("--skip-packages", action="store_true", help="Use already-installed Homebrew dependencies")
    parser.add_argument("--link-only", action="store_true", help="Only back up/link dotfiles; skip dependencies and plugins")
    parser.add_argument("--target", type=Path, default=Path.home(), help="Destination directory (default: your home)")
    args = parser.parse_args()
    target = args.target.expanduser().resolve()
    if target == ROOT or ROOT in target.parents:
        parser.error("Target must not be the repository or inside it")
    if sys.platform != "darwin" and not args.link_only and not args.dry_run:
        parser.error("This setup supports macOS only")
    plugins = json.loads((ROOT / "plugins.json").read_text())
    for plugin in plugins:
        if not re.fullmatch(r"[0-9a-f]{40}", plugin["commit"]):
            raise RuntimeError("Plugin revisions must be full commit SHAs")
        if not plugin["path"].startswith(".vim/pack/") or ".." in Path(plugin["path"]).parts:
            raise RuntimeError("Invalid plugin destination")
    if args.dry_run:
        print(f"Target: {target}")
        if not args.link_only:
            print("Dependencies: existing Homebrew + Xcode Command Line Tools; Brewfile unless --skip-packages")
            for plugin in plugins:
                print(f"Plugin: {plugin['path']} @ {plugin['commit']}")
        for name in FILES:
            print(f"Back up if necessary, then link {target / name} -> {ROOT / name}")
        print("macOS and Terminal preferences are separate opt-in commands; see README.md")
        return
    brew = None
    if not args.link_only:
        if not shutil.which("swiftc") or not shutil.which("git"):
            raise RuntimeError("Install Xcode Command Line Tools first: xcode-select --install")
        run("swiftc", "--version", stdout=subprocess.DEVNULL)
        brew = brew_path()
        if not brew:
            raise RuntimeError("Install Homebrew from https://brew.sh, then run this installer again")
        if not args.skip_packages:
            run(brew, "bundle", "install", "--no-upgrade", "--file", ROOT / "Brewfile")
        run(brew, "bundle", "check", "--file", ROOT / "Brewfile")
        prefix = output(brew, "--prefix")
        vim = str(Path(prefix) / "bin/vim")
    installer = Installer(target)
    if not args.link_only:
        for plugin in plugins:
            installer.plugin(plugin)
            doc = target / plugin["path"] / "doc"
            if doc.is_dir():
                quoted = str(doc).replace("'", "''")
                run(vim, "-u", "NONE", "-i", "NONE", "-n", "-es",
                    "-c", f"execute 'helptags ' . fnameescape('{quoted}')", "-c", "qa!")
        # Build once, before opening Vim, using the already-installed Swift compiler.
        watcher = target / ".vim/pack/vimpostor/start/vim-lumen/autoload/lumen/platforms/macos/watcher"
        if not watcher.exists() or watcher.stat().st_mtime < watcher.with_suffix(".swift").stat().st_mtime:
            run("swiftc", watcher.with_suffix(".swift"), "-o", watcher)
    for name in FILES:
        installer.link(name)
    if not args.link_only:
        run(sys.executable, ROOT / "scripts/doctor.py", "--target", target,
            "--vim", vim)
    print("Done. Open a new terminal and restart Vim.")
    if installer.records:
        print(f"Restore information: {installer.backups / 'manifest.json'}")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError, OSError) as error:
        print(f"Installation failed: {error}", file=sys.stderr)
        sys.exit(1)
