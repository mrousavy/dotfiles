#!/bin/bash
# Entry point; Python 3 comes with the Xcode Command Line Tools on macOS.
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
if ! command -v python3 >/dev/null 2>&1; then
  echo 'Python 3 is required. Install Xcode Command Line Tools: xcode-select --install' >&2
  exit 1
fi
exec python3 "$repo_dir/scripts/install.py" "$@"
