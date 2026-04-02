# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

export TMPDIR="$HOME/tmp"
mkdir -p "$TMPDIR"
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Claude (unset any stale API key env var before launching)
# alias claude='env -u YOUR_KEY_VAR claude'

# GVM disabled - breaks Claude Code shell snapshots (cd function gets captured without helper functions)
# [[ -s "/Users/paulstewart/.gvm/scripts/gvm" ]] && source "/Users/paulstewart/.gvm/scripts/gvm"
# [[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
if [[ -f "$HOME/.dircolors" ]]; then
  eval "$(gdircolors -b "$HOME/.dircolors")"
fi
alias ls='colorls'

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if [[ -r "$HOME/.powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
fi
[[ -r "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Spotify player functions (max 3 instances)
spotify() {
    local count=$(pgrep -f spotify_player | wc -l)
    if [ $count -ge 3 ]; then
        echo "Already 3 spotify_player instances running. Close one first or run: pkill -f spotify_player"
        return 1
    fi
    ~/.cargo/bin/spotify_player
}

spotify_2() {
    local count=$(pgrep -f spotify_player | wc -l)
    if [ $count -ge 3 ]; then
        echo "Already 3 spotify_player instances running. Close one first or run: pkill -f spotify_player"
        return 1
    fi
    /Users/paulstewart/bin/spotify_player
}

# Doghouse Memory System
export DOGHOUSE_USER_ID="paul_stewart"
export DOGHOUSE_USER_NAME="Paul Stewart"
export DOGHOUSE_ORG="dane"

# Doghouse location for Claude skills/commands/agents

# Doghouse
export DOGHOUSE_HOME="/Users/paulstewart/doghouse"

# Interactive completion menu (tab twice to browse with arrows)
zstyle ':completion:*' menu select
autoload -Uz compinit && compinit

# Directory navigation shortcuts
setopt AUTO_CD          # type directory name to cd into it
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases (oh-my-zsh style)
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

# thefuck
eval $(thefuck --alias)

# Zsh plugins
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# API keys (kept out of version control)
[[ -f ~/.secrets ]] && source ~/.secrets

# bun completions
[ -s "/Users/paulstewart/.bun/_bun" ] && source "/Users/paulstewart/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
