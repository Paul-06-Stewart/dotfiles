if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Also works for interactive shells that are not login shells.
if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      break
    fi
  done
fi
typeset -U path
path=("$HOME/.local/bin" "$HOME/bin" "$HOME/.cargo/bin" "$HOME/.bun/bin" $path)
if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
  path=("$HOMEBREW_PREFIX/opt/ruby/bin" $path)
  gem_bins=("$HOMEBREW_PREFIX"/lib/ruby/gems/*/bin(N))
  path=($gem_bins $path)
fi
export GEM_HOME="$HOME/.local/share/gem"
path=("$GEM_HOME/bin" $path)
if [[ -d "${HOMEBREW_PREFIX:-}/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home" ]]; then
  export JAVA_HOME="$HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
  path=("$JAVA_HOME/bin" $path)
fi
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
elif [[ -n "${HOMEBREW_PREFIX:-}" && -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
fi
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"
fpath=("$HOME/.zsh/completions" $fpath)
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
setopt AUTO_CD
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias gst='git status'
alias gco='git checkout'
alias gp='git push'
alias gl='git pull'
alias ga='git add'
alias gc='git commit'
alias gcm='git commit -m'
alias gb='git branch'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'
if command -v colorls >/dev/null; then alias ls='colorls'; fi
if [[ -r "$HOME/.dircolors" ]] && command -v gdircolors >/dev/null; then
  eval "$(gdircolors -b "$HOME/.dircolors")"
fi
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v thefuck >/dev/null && eval "$(thefuck --alias)"
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi
[[ -r "$HOME/.powerlevel10k/powerlevel10k.zsh-theme" ]] && source "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
spotify() {
  local count=$(pgrep -fc spotify_player 2>/dev/null || true)
  if (( ${count:-0} >= 3 )); then
    print 'Already 3 spotify_player instances running.'
    return 1
  fi
  command spotify_player "$@"
}
alias spotify_2='spotify'
[[ -r "$HOME/.secrets" ]] && source "$HOME/.secrets"
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
# Keep Claude on subscription authentication when older parent processes carry keys.
unset ANTHROPIC_API_KEY ANTHROPIC_AUTH_TOKEN ANTHROPIC_BASE_URL ANTHROPIC_MODEL
unset ANTHROPIC_DEFAULT_OPUS_MODEL ANTHROPIC_DEFAULT_SONNET_MODEL ANTHROPIC_DEFAULT_HAIKU_MODEL
unset CLAUDE_CODE_USE_BEDROCK CLAUDE_CODE_USE_VERTEX CLAUDE_CODE_USE_FOUNDRY
unset BIFROST_URL BIFROST_API_KEY BF_VK
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  [[ -r "${HOMEBREW_PREFIX:-}/share/$plugin/$plugin.zsh" ]] && source "$HOMEBREW_PREFIX/share/$plugin/$plugin.zsh"
done
true
