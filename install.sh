#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Files to symlink into $HOME
FILES=(
  .zshrc
  .p10k.zsh
  .dircolors
  .fzf.zsh
)

# Config dirs to symlink into ~/.config/
CONFIG_DIRS=(
  ghostty
)

echo "Installing dotfiles from $DOTFILES_DIR"

for file in "${FILES[@]}"; do
  target="$HOME/$file"
  source="$DOTFILES_DIR/$file"
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "  Backing up existing $target -> ${target}.bak"
    mv "$target" "${target}.bak"
  fi
  ln -sfn "$source" "$target"
  echo "  Linked $target -> $source"
done

mkdir -p "$HOME/.config"
for dir in "${CONFIG_DIRS[@]}"; do
  target="$HOME/.config/$dir"
  source="$DOTFILES_DIR/.config/$dir"
  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "  Backing up existing $target -> ${target}.bak"
    mv "$target" "${target}.bak"
  fi
  ln -sfn "$source" "$target"
  echo "  Linked $target -> $source"
done

echo ""
echo "Done! Dependencies to install:"
echo "  brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting"
echo "  brew install colorls zoxide fzf thefuck direnv pyenv nvm"
echo "  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k"
echo ""
echo "Then restart your shell or run: source ~/.zshrc"
