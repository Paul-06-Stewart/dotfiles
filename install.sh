#!/usr/bin/env bash
set -euo pipefail

echo "=== Terminal Setup ==="
echo ""

# Check for Homebrew
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "Installing dependencies via Homebrew..."
brew install \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  coreutils \
  ruby \
  fzf \
  thefuck \
  direnv \
  zoxide \
  pyenv \
  nvm \
  git-delta \
  git-lfs \
  bat \
  eza \
  fd \
  ripgrep \
  lazygit \
  htop \
  tmux \
  neovim \
  tldr \
  cava

# colorls is a Ruby gem
echo "Installing colorls..."
gem install colorls

# Powerlevel10k
if [[ ! -d "$HOME/.powerlevel10k" ]]; then
  echo "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k
else
  echo "Powerlevel10k already installed."
fi

# TPM (Tmux Plugin Manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  echo "Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  echo "TPM already installed."
fi

# Nerd Font
echo ""
echo "Installing CaskaydiaCove Nerd Font..."
brew install --cask font-caskaydia-cove-nerd-font 2>/dev/null || echo "  (font may already be installed)"

# Karabiner-Elements (keyboard customization)
echo "Installing Karabiner-Elements..."
brew install --cask karabiner-elements 2>/dev/null || echo "  (karabiner may already be installed)"

echo ""
echo "=== Dependencies installed! ==="
echo ""
echo "Next steps — copy the configs you want into place:"
echo ""
echo "  # Shell"
echo "  cp zsh/.zshrc ~/.zshrc"
echo "  cp zsh/.p10k.zsh ~/.p10k.zsh"
echo "  cp zsh/.fzf.zsh ~/.fzf.zsh"
echo "  cp zsh/.dircolors ~/.dircolors"
echo ""
echo "  # Terminal"
echo "  mkdir -p ~/.config/ghostty && cp ghostty/config ~/.config/ghostty/config"
echo ""
echo "  # Git (edit user name/email first!)"
echo "  cp git/.gitconfig ~/.gitconfig"
echo ""
echo "  # Tmux"
echo "  cp tmux/.tmux.conf ~/.tmux.conf"
echo ""
echo "  # Neovim"
echo "  mkdir -p ~/.config/nvim && cp nvim/init.lua ~/.config/nvim/init.lua"
echo ""
echo "  # colorls theme"
echo "  mkdir -p ~/.config/colorls && cp colorls/dark_colors.yaml ~/.config/colorls/dark_colors.yaml"
echo ""
echo "  # Cava (audio visualizer)"
echo "  mkdir -p ~/.config/cava && cp cava/config ~/.config/cava/config"
echo ""
echo "  # Karabiner"
echo "  mkdir -p ~/.config/karabiner && cp karabiner/karabiner.json ~/.config/karabiner/karabiner.json"
echo ""
echo "  # Spotify player"
echo "  mkdir -p ~/.config/spotify-player && cp spotify-player/*.toml ~/.config/spotify-player/"
echo ""
echo "  # API keys"
echo "  touch ~/.secrets && chmod 600 ~/.secrets"
echo ""
echo "Then restart your shell or run: source ~/.zshrc"
echo "For tmux plugins, open tmux and press prefix+I to install."
