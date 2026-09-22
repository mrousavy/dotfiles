# macOS dotfiles

My small zsh + Vim setup for a new Mac. This replaces the old KDE/Konsole setup;
the Linux configuration remains available in Git history.

## New Mac

Requires **macOS 26 or later**, Xcode Command Line Tools (Git, Swift and Python 3),
and [Homebrew](https://brew.sh). Apple Terminal on these macOS versions supports
the true-color Vim themes. Apple silicon and Intel Homebrew paths are supported.

If needed, run `xcode-select --install` and finish Apple's installer. Install
Homebrew using its official instructions. Then keep this checkout somewhere
permanent:

```sh
mkdir -p ~/Projects
git clone https://github.com/mrousavy/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh --dry-run
./install.sh
python3 scripts/doctor.py
```

Open a new Terminal window and restart Vim afterward. The shell prefers
Homebrew's Vim so current completion and bundled commenting features work even
if Apple's bundled Vim is older. The installer checks the required features.

**For an AI agent:**

> Clone mrousavy/dotfiles into ~/Projects/dotfiles, read AGENTS.md and README.md,
> and set up this Mac. Install the prerequisites and dependencies, preserve
> existing configuration using the installer backups, restore the documented
> macOS and Terminal preferences, and run the verification checks. Report any
> remaining manual steps.

## What is installed

| Component | Configuration |
| --- | --- |
| zsh | Dim, adaptive folder prompt; bold input; centered time-of-day greeting; `ls` after changing directories; `..`, `...`, `....` aliases |
| Completion | Case-insensitive Tab matching, highlighted selection, arrow-key navigation |
| zsh plugins | Homebrew's zsh-autosuggestions and zsh-syntax-highlighting |
| Login banner | `.hushlogin` hides “Last login” |
| Vim | Absolute line numbers, no cursor-line highlight, wrapping, two-space indentation, smart-case search, command suggestions while typing |
| Comments/browser | Vim's bundled `comment` package and netrw; no separate commentary or file-tree plugin |
| Vim plugins | GitGutter, vim-lumen and vim-one, pinned in plugins.json |
| Vim appearance | **One Light / One Dark**, selected automatically from macOS appearance |

Vim-lumen compiles a small Swift helper inside its plugin directory. It runs as
a child process while Vim is open and waits for appearance-change notifications.
It installs no system-wide service or login item. Each Vim instance has its own
helper. Theme switching is local to the Mac running Vim, not a remote SSH host.

The `holyclean` command is preserved: it runs **`git clean -dfX`**, deleting
ignored files such as build output. Use it deliberately. Its optional sound is
configured with `HOLYCLEAN_SOUND` in `.zshrc.local`; no old machine's audio path
or media file is included.

## Optional macOS settings

These are deliberately separate from shell/editor installation:

```sh
# Disable ordinary desktop-wallpaper clicks hiding windows.
python3 scripts/macos.py --wallpaper --dry-run
python3 scripts/macos.py --wallpaper

# Restore the captured adaptive Basic-derived Terminal settings.
python3 scripts/macos.py --terminal --dry-run
python3 scripts/macos.py --terminal
```

The Terminal import requires **Apple Terminal to be closed** so it cannot
overwrite preferences on exit. Run it from another terminal app or an agent's
shell. It adds a profile named **Dotfiles** and makes it the startup/default
profile, retaining other profiles. The profile captures the current font and
window preferences without fixed RGB colors, so it follows system appearance.
The separate Vim colorscheme supplies One Light/Dark inside the editor.

Existing macOS preference domains are backed up first. No other Dock, app,
account, security, keyboard, or window-manager preferences are applied. Magnet
and other personal apps are not prerequisites for these dotfiles.

## Backups, local changes, and repeat runs

- `install.sh` links `.zshrc`, `.vimrc` and `.hushlogin` to this checkout. Keep the
  checkout in place; editing a linked file edits the repository.
- Replaced files, links and plugin directories go to
  `~/.local/state/dotfiles/backups/<timestamp>/`, with a `manifest.json` mapping
  original paths to backups. Restore by removing the installed link and moving
  the corresponding backup to its original path. Do not delete the backup first.
- An identical link/plugin is left alone on subsequent runs. A different or
  modified plugin checkout is backed up, not reset. A failed plugin download
  leaves the previous plugin in place.
- Homebrew dependencies come from Brewfile and follow available Homebrew
  releases; they are not binary-version locked. Installation uses `--no-upgrade`.
  Review and run `brew upgrade vim zsh-autosuggestions zsh-syntax-highlighting`
  when you want newer releases. Rerun the doctor after upgrades.
- `.zshrc.local` and `.vimrc.local` hold machine-specific settings/secrets and
  are not committed. Existing `.zprofile`, Git identity, SSH configuration,
  language managers and shell history are not replaced.
- Put optional personal Homebrew packages in ignored `Brewfile.local` and run
  `brew bundle --file=Brewfile.local` separately.
- `--skip-packages` skips package installation but verifies dependencies;
  `--link-only` only installs the three links (plugins must already exist).
- `--target /some/directory` installs into another destination for testing.
  Never point it at the repository itself. It does not change HOME or redirect
  Homebrew: a full install still uses the Mac's Homebrew installation.
- No automatic plugin updates: change reviewed commit SHAs in plugins.json,
  run the installer again, and verify. Git history is the change log.

## Everyday keys

| Vim keys | Action |
| --- | --- |
| `Esc` | Cancel a pending command / return to Normal mode |
| Space then `e` | Toggle netrw's left sidebar |
| `Ctrl+w`, then `h/j/k/l` | Focus left/down/up/right split |
| `Ctrl+w`, then `>` / `<` | Widen / narrow the focused split |
| `gcc` / visual selection then `gc` | Toggle comments |
| Space then `h` | Clear search highlighting |
| `[c` / `]c` | Previous / next Git change |
| Space then `h p` / `h s` / `h u` | Preview / stage / undo a Git hunk |
| `:w`, `:q` | Save / close |

The short Space-h mapping shares a prefix with GitGutter's longer mappings;
Vim briefly waits to see whether you continue with `p`, `s` or `u`.
Normal terminal Command-C/V remain available; Vim's clipboard is not globally
redirected. Mouse mode and persistent undo are not enabled.

## Verification

```sh
bash -n install.sh
zsh -n .zshrc
python3 -m unittest discover -s tests -v
python3 scripts/doctor.py
```

The doctor checks plugin revisions, shell completion, Vim mappings/preferences,
both actual theme palettes, and the running appearance helper. CI also installs
twice into an isolated destination to exercise repeat runs. It does not change
the user's macOS appearance. In a real Terminal window, also verify Tab menu
highlighting and toggle macOS appearance while Vim is open. Color rendering and
OS notification delivery need that final visual check.
