# Homebrew supports both Apple Silicon and Intel Macs.
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [[ -x "$brew_bin" ]]; then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done
typeset -U path
path=("$HOME/.local/bin" "$HOME/bin" $path)
[[ -r "$HOME/.zprofile.local" ]] && source "$HOME/.zprofile.local"
