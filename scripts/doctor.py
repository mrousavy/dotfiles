#!/usr/bin/env python3
"""Check installed files, pinned plugins, shell completion and live Vim support."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def quote_vim(value):
    return "'" + str(value).replace("'", "''") + "'"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--target", type=Path, default=Path.home())
    parser.add_argument("--vim", default=shutil.which("vim"))
    args = parser.parse_args()
    target = args.target.expanduser().resolve()
    if not args.vim:
        raise RuntimeError("Vim is not installed")
    for name in (".zshrc", ".vimrc", ".hushlogin", ".config/git/ignore"):
        if not (target / name).is_file():
            raise RuntimeError(f"Missing {target / name}")
    for plugin in json.loads((ROOT / "plugins.json").read_text()):
        installed = target / plugin["path"]
        revision = subprocess.check_output(["git", "-C", str(installed), "rev-parse", "HEAD"], text=True).strip()
        if revision != plugin["commit"]:
            raise RuntimeError(f"{plugin['name']} differs from plugins.json")
    with tempfile.TemporaryDirectory(prefix="dotfiles-check-") as temp:
        scratch = Path(temp)
        shell_check = '''
source "$1"
(( $+functions[_zsh_autosuggest_start] && $+functions[_zsh_highlight] && $+functions[_main_complete] )) || exit 1
zstyle -a ':completion:*' matcher-list matchers
[[ "$matchers" == 'm:{a-zA-Z}={A-Za-z}' ]] || exit 1
zstyle -a ':completion:*' menu selection
[[ "$selection" == select ]] || exit 1
[[ ${aliases[..]} == 'cd ..' && ${aliases[...]} == 'cd ../..' ]] || exit 1
[[ ${aliases[....]} == 'cd ../../..' ]] || exit 1
[[ $(bindkey '^[[A') == *' history-beginning-search-backward' ]] || exit 1
[[ $(bindkey '^[[B') == *' history-beginning-search-forward' ]] || exit 1
'''
        env = dict(os.environ, ZDOTDIR=str(scratch))
        subprocess.run(["/bin/zsh", "-dfic", shell_check, "dotfiles-check", str(target / ".zshrc")],
                       env=env, check=True)
        check = scratch / "check.vim"
        report = scratch / "report.json"
        check.write_text('''
call assert_true(exists('*wildtrigger'), 'Vim must support command-line autocompletion')
call assert_false(empty(maparg('gcc', 'n')), 'Bundled comment mappings missing')
call assert_equal(':Lexplore<CR>', maparg(' e', 'n'))
call assert_true(exists(':GitGutter'), 'GitGutter did not load')
call assert_equal(1, &number)
call assert_equal(0, &relativenumber)
call assert_equal(0, &cursorline)
call assert_equal(1, &wrap)
call assert_equal('one', get(g:, 'colors_name', ''))
call lumen#light_hook()
call assert_equal('light', &background)
call assert_equal('#fafafa', synIDattr(hlID('Normal'), 'bg', 'gui'))
call lumen#dark_hook()
call assert_equal('dark', &background)
call assert_equal('#282c34', synIDattr(hlID('Normal'), 'bg', 'gui'))
call lumen#oneshot()
call lumen#fork_job()
sleep 300m
let info = lumen#debug#info()
call assert_equal('run', info.job_state, 'macOS appearance listener is not running')
call assert_equal([], info.job_errors)
''' + f"call writefile([json_encode({{'errors': v:errors, 'appearance': &background, 'listener': info}})], {quote_vim(report)})\n"
                         + "if !empty(v:errors)\n  cquit\nendif\nqa!\n")
        command = [args.vim, "-N", "-u", str(target / ".vimrc"), "-i", "NONE", "-n", "-es",
                   "--cmd", f"let &packpath = {quote_vim(target / '.vim')} . ',' . $VIMRUNTIME",
                   "--cmd", f"let &runtimepath = {quote_vim(target / '.vim')} . ',' . $VIMRUNTIME",
                   "-S", str(check)]
        result = subprocess.run(command, capture_output=True, text=True)
        if report.exists():
            data = json.loads(report.read_text())
            if data["errors"]:
                raise RuntimeError("\n".join(data["errors"]))
        if result.returncode:
            raise RuntimeError("Vim check failed. " + result.stderr + result.stdout)
        if not report.exists():
            raise RuntimeError("Vim exited without completing its verification")
        print(f"Verified: zsh plugins/completion, Vim config, One Light/Dark, and macOS listener ({data['appearance']}).")
        print("Manual check in Apple Terminal: open Vim, switch macOS appearance, then try Space e and :edit completion.")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, subprocess.CalledProcessError, OSError) as error:
        print(f"Check failed: {error}", file=sys.stderr)
        sys.exit(1)
