#!/bin/bash
set -euo pipefail
# Download this file and run it, or: curl -fsSL URL | bash -s -- [options]
if [[ "$(uname -s)" != Darwin ]]; then echo 'macOS required.' >&2; exit 1; fi
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo 'Finish installing Command Line Tools, then run this command again.'
  exit 1
fi
repo='https://github.com/Paul-06-Stewart/dotfiles.git'
destination="${DOTFILES_DIR:-$HOME/.local/share/paul-dotfiles}"
if [[ -e "$destination" ]]; then
  echo "Destination exists: $destination. Run its install.sh or choose DOTFILES_DIR." >&2
  exit 1
fi
mkdir -p "$(dirname "$destination")"
git clone --branch main --single-branch "$repo" "$destination"
# Restore interactive input after a curl pipe so sudo/Homebrew can prompt.
if [[ ! -t 0 && -r /dev/tty ]]; then
  exec /bin/bash "$destination/install.sh" "$@" </dev/tty
fi
exec /bin/bash "$destination/install.sh" "$@"
