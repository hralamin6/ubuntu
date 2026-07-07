#!/usr/bin/env zsh
# =============================================================================
# aliases/filesystem.sh — File system operation aliases
# =============================================================================

# ---------------------------------------------------------------------------
# FILE VIEWING (BAT)
# ---------------------------------------------------------------------------
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
  alias catn='bat --style=plain --paging=never'
  alias catp='bat --paging=always'
  alias bats='bat --style=numbers,changes'
elif command -v batcat &>/dev/null; then
  alias cat='batcat --paging=never'
  alias catn='batcat --style=plain --paging=never'
  alias catp='batcat --paging=always'
fi

# ---------------------------------------------------------------------------
# FILE OPERATIONS
# ---------------------------------------------------------------------------
alias cp='cp -iv'                       # Interactive, verbose
alias mv='mv -iv'                       # Interactive, verbose
alias rm='rm -iv'                       # Interactive, verbose
alias rmf='rm -rf'                      # Force recursive (be careful!)
alias mkdir='mkdir -pv'                 # Create parents, verbose
alias md='mkdir -pv'                    # Short alias
alias touch='touch'
alias ln='ln -iv'                       # Interactive, verbose symlink

# Safe alternatives
alias rmi='rm -ri'                      # Always interactive rm
alias cpr='cp -r'                       # Recursive copy
alias cpL='cp -rL'                      # Follow symlinks when copying

# ---------------------------------------------------------------------------
# DISK USAGE
# ---------------------------------------------------------------------------
if command -v dust &>/dev/null; then
  alias du='dust'
  alias duh='dust --reverse'
elif command -v dua &>/dev/null; then
  alias du='dua'
else
  alias du='du -h'
  alias duh='du -h --max-depth=1 | sort -hr'
fi

alias df='df -h'                        # Human readable
alias dfa='df -ah'                      # All filesystems
alias dfT='df -hT'                      # Include filesystem type

# ---------------------------------------------------------------------------
# FIND
# ---------------------------------------------------------------------------
if command -v fd &>/dev/null; then
  alias find='fd'
  alias ff='fd --type f'               # Find files only
  alias fd='fd'                        # keep fd alias too
  alias fdir='fd --type d'            # Find directories
  alias fsym='fd --type l'            # Find symlinks
  alias fexec='fd --type x'           # Find executables
else
  alias ff='find . -type f'
  alias fdir='find . -type d'
  alias fsym='find . -type l'
fi

# ---------------------------------------------------------------------------
# SEARCH (RIPGREP)
# ---------------------------------------------------------------------------
if command -v rg &>/dev/null; then
  alias grep='rg'
  alias grep='rg --color=always'
  alias rgi='rg -i'                   # Case insensitive
  alias rgf='rg --files'              # List files that would be searched
  alias rgl='rg -l'                   # Files with matches
  alias rgn='rg --line-number'
  alias rgh='rg --hidden'             # Include hidden files
  alias rgw='rg --word-regexp'        # Whole word matches
else
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
fi

# ---------------------------------------------------------------------------
# PERMISSIONS
# ---------------------------------------------------------------------------
alias chx='chmod +x'                   # Make executable
alias chpub='chmod 644'               # Public read
alias chsec='chmod 600'               # Private (keys, etc.)
alias chdir='chmod 755'               # Directory default
alias chown='chown -v'

# ---------------------------------------------------------------------------
# ARCHIVES — quick compression
# ---------------------------------------------------------------------------
alias mktar='tar -cvf'
alias mktargz='tar -czvf'
alias mktarbz2='tar -cjvf'
alias mkzip='zip -r'
alias mk7z='7z a'

# Quick extraction
alias untar='tar -xvf'
alias untargz='tar -xzvf'
alias untarbz2='tar -xjvf'
alias unzip='unzip -v'

# ---------------------------------------------------------------------------
# SYMLINKS
# ---------------------------------------------------------------------------
alias lns='ln -sf'                     # Soft symlink
alias lnh='ln -f'                      # Hard link
alias readlink='readlink -f'           # Always resolve

# ---------------------------------------------------------------------------
# CHECKSUM
# ---------------------------------------------------------------------------
alias md5='md5sum'
alias sha1='sha1sum'
alias sha256='sha256sum'
alias sha512='sha512sum'

# ---------------------------------------------------------------------------
# DIFF
# ---------------------------------------------------------------------------
alias diff='diff --color=auto'
alias vimdiff='nvim -d'

# ---------------------------------------------------------------------------
# FILE INFO
# ---------------------------------------------------------------------------
alias file='file -b'                   # Brief output
alias stat='stat -c "%n: %F, %s bytes, permissions: %A, modified: %y"'
alias which='which -a'                 # Show all matches
alias type='type -a'                   # Show all types

# ---------------------------------------------------------------------------
# CLIPBOARD
# ---------------------------------------------------------------------------
if command -v xclip &>/dev/null; then
  alias pbcopy='xclip -selection clipboard'
  alias pbpaste='xclip -selection clipboard -o'
  alias clip='xclip -selection clipboard'
elif command -v wl-copy &>/dev/null; then
  alias pbcopy='wl-copy'
  alias pbpaste='wl-paste'
  alias clip='wl-copy'
elif command -v xsel &>/dev/null; then
  alias pbcopy='xsel --clipboard --input'
  alias pbpaste='xsel --clipboard --output'
fi

# ---------------------------------------------------------------------------
# MISC
# ---------------------------------------------------------------------------
alias tree='tree -C'                    # Color output
alias wc='wc -l'                        # Default to line count
alias head='head -20'                   # Show 20 lines by default
alias tail='tail -20'                   # Show 20 lines by default
alias tailf='tail -f'                   # Follow mode
alias less='less -R'                    # Raw control chars (colors)
alias more='less'                       # Always use less
