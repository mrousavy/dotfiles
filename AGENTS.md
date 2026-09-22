# Working on these dotfiles

This repository is the macOS setup. The historical KDE files are deprecated;
do not restore them from Git history unless explicitly requested.

## Setting up a Mac

1. Read README.md, Brewfile, plugins.json and the installer before running it.
2. Check the platform, `xcode-select -p`, `swiftc --version`, and Homebrew.
   Install missing prerequisites from Apple's or Homebrew's official sources
   when the user asks you to set up the machine. Let the user complete any
   required OS authentication; never handle passwords in scripts.
3. Clone into a durable directory such as `~/Projects/dotfiles`. Symlinks point
   to this checkout, so do not install from a temporary directory.
4. Run `./install.sh --dry-run`, then `./install.sh`, then
   `python3 scripts/doctor.py`. Read and resolve failures before reporting success.
5. Restore `--wallpaper` and/or `--terminal` with scripts/macos.py when included
   in the user's requested setup. Never quit Terminal and its running sessions
   on their behalf just to import a profile. Other shell tools can run the
   import after the user has closed Terminal.
6. Tell the user which settings changed, where backups are, and which manual
   checks remain. Start a new Terminal session; verify the greeting, dim prompt,
   bold input, case-insensitive completion and highlighted selection. Open Vim
   in a Git repo; verify the sidebar, Git markers, and both system appearances.

## Editing and updating

- Keep comments above settings. Preserve the user's existing preferences.
- Do not collect credentials, shell history, SSH keys, private account settings,
  or arbitrary home-directory files. Local overrides remain untracked.
- Never reset a dirty plugin checkout or overwrite dotfiles without backups.
- Vim plugins are pinned in plugins.json. Review upstream changes before
  updating a SHA; the installer must not follow moving branch heads silently.
- Keep Apple silicon and Intel paths working. No hardcoded username or absolute
  checkout path belongs in tracked configuration.
- Run `bash -n install.sh`, `zsh -n .zshrc`,
  `python3 -m unittest discover -s tests -v`, and the doctor after relevant changes.
- Test installation with `--target` in a temporary directory. Do not change
  HOME to test, and do not apply macOS preferences during automated tests.
- Do not add cloud services, launch agents, login items, global Git identity,
  editor distributions, or personal applications merely to install these files.
