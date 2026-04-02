# dotfiles

My macOS terminal setup — Zsh + Powerlevel10k + Ghostty + tmux + Neovim.

## What's included

| Folder | What | Highlights |
|--------|------|------------|
| `zsh/` | Shell config | Powerlevel10k prompt, zsh-autosuggestions, zsh-syntax-highlighting, fzf, zoxide, thefuck, colorls with Catppuccin colors |
| `ghostty/` | Terminal emulator | CaskaydiaCove Nerd Font, 256color |
| `tmux/` | Terminal multiplexer | Ctrl+a prefix, vim-style pane nav, Catppuccin-inspired theme, TPM + resurrect |
| `nvim/` | Neovim | lazy.nvim, nightfly colorscheme, treesitter |
| `git/` | Git config | Delta side-by-side diffs, LFS |
| `colorls/` | `ls` replacement theme | Catppuccin dark colors |
| `cava/` | Audio visualizer | Terminal audio visualizer config |
| `karabiner/` | Keyboard remapping | Karabiner-Elements config |
| `spotify-player/` | TUI Spotify client | Theme + playback settings |

## Quick start

```bash
git clone https://github.com/Paul-06-Stewart/dotfiles.git
cd dotfiles
./install.sh
```

This installs all dependencies (Homebrew, CLI tools, fonts, plugins). Then copy whichever configs you want:

```bash
# Shell
cp zsh/.zshrc ~/.zshrc
cp zsh/.p10k.zsh ~/.p10k.zsh
cp zsh/.fzf.zsh ~/.fzf.zsh
cp zsh/.dircolors ~/.dircolors

# Terminal
mkdir -p ~/.config/ghostty && cp ghostty/config ~/.config/ghostty/config

# Git (edit name/email first!)
cp git/.gitconfig ~/.gitconfig

# Tmux
cp tmux/.tmux.conf ~/.tmux.conf

# Neovim
mkdir -p ~/.config/nvim && cp nvim/init.lua ~/.config/nvim/init.lua

# colorls
mkdir -p ~/.config/colorls && cp colorls/dark_colors.yaml ~/.config/colorls/dark_colors.yaml

# Cava
mkdir -p ~/.config/cava && cp cava/config ~/.config/cava/config

# Spotify player
mkdir -p ~/.config/spotify-player && cp spotify-player/*.toml ~/.config/spotify-player/
```

Then restart your shell or `source ~/.zshrc`.

For tmux plugins, open tmux and press `prefix + I` to install.

## API keys

Create a `~/.secrets` file for any API keys — the `.zshrc` sources it automatically:

```bash
touch ~/.secrets && chmod 600 ~/.secrets
```

## Key tools

| Tool | What it does |
|------|-------------|
| [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | Fast, customizable Zsh prompt |
| [Ghostty](https://ghostty.org) | GPU-accelerated terminal |
| [delta](https://github.com/dandavison/delta) | Better git diffs |
| [colorls](https://github.com/athityakumar/colorls) | Pretty `ls` with icons |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [thefuck](https://github.com/nvbn/thefuck) | Auto-correct previous command |
| [bat](https://github.com/sharkdp/bat) | `cat` with syntax highlighting |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement |
| [lazygit](https://github.com/jesseduffield/lazygit) | TUI git client |
| [spotify_player](https://github.com/aome510/spotify-player) | TUI Spotify client |

## Font

This setup uses [CaskaydiaCove Nerd Font Mono](https://www.nerdfonts.com/) — the install script grabs it via Homebrew. Set it in your terminal emulator for the icons to render correctly.
