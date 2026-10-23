#!/bin/bash
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_EDITOR_CHECK="$ROOT/scripts/editor-check.lua"
failures=0
check() {
  if "$@"; then printf 'PASS %s\n' "$*"; else printf 'FAIL %s\n' "$*"; failures=$((failures + 1)); fi
}
check test -r "$HOME/.p10k.zsh"
check test -r "$HOME/.tmux.conf"
check test -r "$HOME/.config/lvim/lazy-lock.json"
check test -r "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
check test -r "$HOME/.config/ghostty/themes/Soft Latte"
check test -r "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
check test -x "$HOME/.tmux/plugins/tpm/tpm"
check "$HOME/.local/bin/nvim" --version
check "$HOME/.local/bin/lvim" --headless -c 'lua dofile(vim.env.DOTFILES_EDITOR_CHECK)' +qa
check zsh -n "$HOME/.zshrc"
check zsh -n "$HOME/.zprofile"
check git config --global --includes --get user.name
check git config --global --includes --get user.email
printf '\n%d failed checks. App sign-ins, Tailscale enrollment, and macOS permissions need manual verification.\n' "$failures"
exit "$failures"
