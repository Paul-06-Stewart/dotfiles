#!/bin/bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_only=0
dry_run=0
apps=0
for arg in "$@"; do
  case "$arg" in
    --config-only) config_only=1 ;;
    --dry-run) dry_run=1 ;;
    --apps) apps=1 ;;
    --macos|--karabiner) ;;
    --help|-h)
      echo 'Usage: ./install.sh [--dry-run] [--config-only] [--apps] [--macos] [--karabiner]'
      echo 'Default: dependencies, backed-up configs, pinned LunarVim, plugins, and language servers.'
      echo '--config-only: configs only; no downloads or package installation (requires Python 3).'
      echo '--dry-run: print the plan without downloads or writes (requires Python 3).'
      echo '--apps: install optional desktop apps. --karabiner: also apply keyboard mappings.'
      echo '--macos: apply the captured Dock, Finder, and screenshot settings.'
      exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done
if [[ "$(uname -s)" != Darwin ]]; then echo 'This installer requires macOS.' >&2; exit 1; fi
if [[ "$dry_run" == 0 && "$config_only" == 0 ]]; then
  if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    echo 'Finish installing Command Line Tools, then rerun ./install.sh.'
    exit 1
  fi
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then eval "$("$brew_bin" shellenv)"; break; fi
  done
  if ! command -v brew >/dev/null; then
    installer="$(mktemp)"
    curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"
    /bin/bash "$installer"
    rm "$installer"
    for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
      if [[ -x "$brew_bin" ]]; then eval "$("$brew_bin" shellenv)"; break; fi
    done
  fi
  brew bundle install --file="$ROOT/Brewfile" --no-upgrade
  if [[ "$apps" == 1 ]]; then brew bundle install --file="$ROOT/Brewfile.apps" --no-upgrade; fi
fi
exec python3 "$ROOT/scripts/install.py" "$@"
