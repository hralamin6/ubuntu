#!/usr/bin/env zsh
# =============================================================================
# aliases/system.sh — System management aliases
# =============================================================================

# ---------------------------------------------------------------------------
# PROCESS MANAGEMENT
# ---------------------------------------------------------------------------
if command -v procs &>/dev/null; then
  alias ps='procs'
  alias psa='procs --sortd cpu'
else
  alias ps='ps auxf'
  alias psa='ps auxf | sort -nrk 3 | head -20'
fi

alias psg='ps aux | grep'
alias psn='ps aux --sort=pcpu | head -20'   # Top CPU processes
alias psm='ps aux --sort=pmem | head -20'   # Top memory processes

# ---------------------------------------------------------------------------
# SYSTEM RESOURCES
# ---------------------------------------------------------------------------
if command -v btop &>/dev/null; then
  alias top='btop'
  alias htop='btop'
elif command -v htop &>/dev/null; then
  alias top='htop'
fi

if command -v bottom &>/dev/null; then
  alias btm='bottom'
fi

alias uptime='uptime -p'
alias free='free -h'
alias freem='free -m'
alias vmstat='vmstat -s'
alias iostat='iostat -xh'

# ---------------------------------------------------------------------------
# SYSTEMD
# ---------------------------------------------------------------------------
# Aliased in systemd.sh — here just core shortcuts
alias sc='systemctl'
alias scs='systemctl status'
alias scst='systemctl start'
alias scsp='systemctl stop'
alias scrs='systemctl restart'
alias scea='systemctl enable --now'
alias scda='systemctl disable --now'
alias scld='systemctl list-dependencies'
alias sclu='systemctl list-units'
alias scluf='systemctl list-unit-files'
alias scjl='journalctl'
alias scjf='journalctl -f'
alias scju='journalctl -u'
alias scjuf='journalctl -u -f'
alias scjb='journalctl -b'                  # Current boot
alias scjbn='journalctl -b -1'              # Previous boot
alias scjp='journalctl -p err'              # Error priority+
alias scjr='journalctl --rotate'
alias scjv='journalctl --vacuum-time=7d'   # Vacuum old logs

# Sudo variants
alias ssc='sudo systemctl'
alias sscs='sudo systemctl status'
alias sscst='sudo systemctl start'
alias sscsp='sudo systemctl stop'
alias sscrs='sudo systemctl restart'
alias sscea='sudo systemctl enable --now'
alias sscda='sudo systemctl disable --now'
alias sscr='sudo systemctl daemon-reload'
alias sscjf='sudo journalctl -f'

# ---------------------------------------------------------------------------
# PACKAGE MANAGEMENT (APT)
# ---------------------------------------------------------------------------
alias aptup='sudo apt-get update'
alias aptupg='sudo apt-get upgrade -y'
alias aptfull='sudo apt-get update && sudo apt-get full-upgrade -y'
alias apti='sudo apt-get install -y'
alias aptr='sudo apt-get remove -y'
alias aptpr='sudo apt-get purge -y'
alias apts='apt-cache search'
alias aptsh='apt-cache show'
alias aptpol='apt-cache policy'
alias aptdep='apt-cache depends'
alias aptaut='sudo apt-get autoremove --purge -y'
alias aptcl='sudo apt-get clean && sudo apt-get autoclean'
alias aptlist='apt list --installed 2>/dev/null | less'
alias aptlupg='apt list --upgradable 2>/dev/null'
alias dpkgl='dpkg -l | grep'
alias dpkgq='dpkg -s'
alias dpkgf='dpkg -L'                         # Files from package

# ---------------------------------------------------------------------------
# USER MANAGEMENT
# ---------------------------------------------------------------------------
alias adduser='sudo adduser'
alias usermod='sudo usermod'
alias userdel='sudo userdel'
alias groupadd='sudo groupadd'
alias groups='groups $(whoami)'
alias id='id $(whoami)'
alias who='who -a'
alias w='w -h'
alias last='last -a | head -20'
alias lastb='sudo lastb | head -20'           # Failed logins
alias loggedin='who | awk "{print $1}" | sort | uniq'

# ---------------------------------------------------------------------------
# DISK / FILESYSTEM
# ---------------------------------------------------------------------------
alias mount='mount | column -t'
alias umount='sudo umount'
alias remount='sudo mount -o remount,rw'
alias fsck='sudo fsck'
alias lsblk='lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT,LABEL'
alias blkid='sudo blkid'
alias fstab='cat /etc/fstab'

# ---------------------------------------------------------------------------
# KERNEL / HARDWARE
# ---------------------------------------------------------------------------
alias uname='uname -a'
alias cpuinfo='cat /proc/cpuinfo | grep "model name" | head -1'
alias meminfo='cat /proc/meminfo'
alias lshw='sudo lshw -short 2>/dev/null'
alias lspci='lspci -tv'
alias lsusb='lsusb -tv'
alias dmesg='sudo dmesg --color=always | less -R'
alias dmsg='sudo dmesg --color=always --level=err,crit,alert,emerg'

# ---------------------------------------------------------------------------
# POWER
# ---------------------------------------------------------------------------
alias reboot='sudo reboot'
alias shutdown='sudo shutdown -h now'
alias poweroff='sudo poweroff'
alias suspend='sudo systemctl suspend'
alias hibernate='sudo systemctl hibernate'

# ---------------------------------------------------------------------------
# CRON
# ---------------------------------------------------------------------------
alias crontab='crontab -e'
alias crontabs='crontab -l'
alias cronroot='sudo crontab -e'

# ---------------------------------------------------------------------------
# ENVIRONMENT
# ---------------------------------------------------------------------------
alias env='env | sort'
alias path='echo ${PATH} | tr ":" "\n"'
alias exports='export | sort'
alias fns='typeset -f | head -200'
alias aliases='alias | sort'
