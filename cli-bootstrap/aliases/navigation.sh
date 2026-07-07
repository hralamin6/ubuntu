#!/usr/bin/env zsh
# =============================================================================
# aliases/navigation.sh — Directory navigation aliases
# =============================================================================

# ---------------------------------------------------------------------------
# QUICK DIRECTORY SHORTCUTS
# ---------------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias -- -='cd -'           # Go to previous directory

# ---------------------------------------------------------------------------
# COMMON LOCATIONS
# ---------------------------------------------------------------------------
alias home='cd ~'
alias root='cd /'
alias tmp='cd /tmp'
alias etc='cd /etc'
alias log='cd /var/log'
alias srv='cd /srv'
alias opt='cd /opt'
alias web='cd /var/www'
alias www='cd /var/www/html'
alias nginx='cd /etc/nginx'
alias apache='cd /etc/apache2'

# ---------------------------------------------------------------------------
# PUSHD / POPD
# ---------------------------------------------------------------------------
alias pu='pushd'
alias po='popd'
alias dirs='dirs -v | head -20'

# ---------------------------------------------------------------------------
# LISTING (EZA — enhanced ls)
# ---------------------------------------------------------------------------
if command -v eza &>/dev/null; then
  alias ls='eza --color=always --group-directories-first --icons'
  alias ll='eza --color=always --long --all --group-directories-first --icons --git'
  alias la='eza --color=always --long --all --group-directories-first --icons'
  alias l='eza --color=always --long --group-directories-first --icons'
  alias lt='eza --color=always --tree --level=2 --icons --group-directories-first'
  alias ltt='eza --color=always --tree --level=3 --icons --group-directories-first'
  alias lttt='eza --color=always --tree --level=4 --icons --group-directories-first'
  alias lta='eza --color=always --tree --all --level=3 --icons'
  alias lr='eza --color=always --long --all --sort=modified --reverse --icons'
  alias lsize='eza --color=always --long --all --sort=size --reverse --icons'
  alias lext='eza --color=always --long --all --sort=extension --icons'
else
  # Fallback to regular ls
  alias ls='ls --color=auto --group-directories-first'
  alias ll='ls -lhA --color=auto --group-directories-first'
  alias la='ls -A --color=auto'
  alias l='ls -lh --color=auto'
  alias lt='find . -maxdepth 2 -printf "%T+ %p\n" | sort'
fi

# ---------------------------------------------------------------------------
# ZOXIDE SHORTCUTS (smart cd)
# ---------------------------------------------------------------------------
if command -v zoxide &>/dev/null; then
  alias z='zoxide query --interactive'
  alias zi='zoxide query --interactive'
  alias za='zoxide add'
  alias zl='zoxide query --list'
  alias zr='zoxide remove'
fi

# ---------------------------------------------------------------------------
# NAVIGATION WITH FZF
# ---------------------------------------------------------------------------
alias cdf='cd "$(find . -type d | fzf --preview "eza --tree --color=always {}" --height=60%)"'
alias lf='eza --long --all --color=always | fzf --ansi'

# ---------------------------------------------------------------------------
# QUICK EDITS
# ---------------------------------------------------------------------------
alias zshrc='${EDITOR:-nvim} ~/.zshrc'
alias zshenv='${EDITOR:-nvim} ~/.zshenv'
alias zprofile='${EDITOR:-nvim} ~/.zprofile'
alias sshconf='${EDITOR:-nvim} ~/.ssh/config'
alias hostsfile='sudo ${EDITOR:-nvim} /etc/hosts'
alias vimrc='${EDITOR:-nvim} ~/.config/nvim/init.lua'
alias tmuxconf='${EDITOR:-nvim} ~/.tmux.conf'
alias starshipconf='${EDITOR:-nvim} ~/.config/starship.toml'
