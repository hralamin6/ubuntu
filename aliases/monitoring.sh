#!/usr/bin/env zsh
# =============================================================================
# aliases/monitoring.sh — Monitoring, logs, performance aliases
# =============================================================================

# ---------------------------------------------------------------------------
# LOG VIEWING
# ---------------------------------------------------------------------------
alias lognginx='sudo tail -f /var/log/nginx/access.log'
alias lognginxerr='sudo tail -f /var/log/nginx/error.log'
alias logapache='sudo tail -f /var/log/apache2/access.log'
alias logapacheerr='sudo tail -f /var/log/apache2/error.log'
alias logsyslog='sudo tail -f /var/log/syslog'
alias logauth='sudo tail -f /var/log/auth.log'
alias logmail='sudo tail -f /var/log/mail.log'
alias logkern='sudo tail -f /var/log/kern.log'
alias logdmesg='sudo dmesg --color=always --follow'
alias logfail2ban='sudo tail -f /var/log/fail2ban.log'
alias loglara='tail -f storage/logs/laravel.log'
alias loglaraclr='> storage/logs/laravel.log && echo "Laravel log cleared"'

# Journalctl shortcuts
alias jlog='journalctl -n 100'
alias jlogf='journalctl -f'
alias jloge='journalctl -p err -n 50'
alias jlogb='journalctl -b'
alias jlogbn='journalctl -b -1'
alias jlogu='journalctl -u'
alias jloguf='journalctl -u -f'
alias jlogmem='journalctl --disk-usage'
alias jlogvac='sudo journalctl --vacuum-time=7d'

# ---------------------------------------------------------------------------
# SYSTEM MONITORING
# ---------------------------------------------------------------------------
if command -v btop &>/dev/null; then
  alias monitor='btop'
elif command -v htop &>/dev/null; then
  alias monitor='htop'
else
  alias monitor='top'
fi

alias cpumon='watch -n1 "cat /proc/cpuinfo | grep MHz"'
alias cputemp='cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | awk "{print \$1/1000 \"°C\"}"'
alias memmon='watch -n1 free -h'
alias diskmon='watch -n1 df -h'

# ---------------------------------------------------------------------------
# PROCESS MONITORING
# ---------------------------------------------------------------------------
alias pscpu='ps aux --sort=-%cpu | head -20'
alias psmem='ps aux --sort=-%mem | head -20'
alias psname='ps aux | grep'
alias pstree='ps axjf'
alias pskill='kill -9'
alias psgrep='pgrep -la'

if command -v procs &>/dev/null; then
  alias pscpu='procs --sortd cpu'
  alias psmem='procs --sortd mem'
fi

# ---------------------------------------------------------------------------
# DISK I/O
# ---------------------------------------------------------------------------
alias iotop='sudo iotop -o'
alias dstat='dstat -cdngy 1'
alias iostat='iostat -xhd 1'
alias vmstat='vmstat 1 10'

# ---------------------------------------------------------------------------
# NETWORK MONITORING
# ---------------------------------------------------------------------------
alias netstat='ss -tulpn'
alias netstatall='ss -atupn'
alias netstatest='ss -tn state established'
alias nethogs='sudo nethogs'
alias iftop='sudo iftop'
alias tcpdump='sudo tcpdump'
alias tcpdumping='sudo tcpdump -i any port'
alias netwatch='watch -n1 "ss -tulpn"'

# ---------------------------------------------------------------------------
# PERFORMANCE TOOLS
# ---------------------------------------------------------------------------
if command -v hyperfine &>/dev/null; then
  alias bench='hyperfine'
  alias benchmark='hyperfine --warmup 5'
fi

alias time='/usr/bin/time -v'
alias strace='strace -e trace=open,read,write'
alias ltrace='ltrace -e malloc,free'
alias perf='sudo perf'

# ---------------------------------------------------------------------------
# UPTIME / LOAD
# ---------------------------------------------------------------------------
alias uptime='uptime -p'
alias loadavg='cat /proc/loadavg'
alias uptimef='uptime && cat /proc/loadavg'

# ---------------------------------------------------------------------------
# FAIL2BAN
# ---------------------------------------------------------------------------
if command -v fail2ban-client &>/dev/null; then
  alias f2bst='sudo fail2ban-client status'
  alias f2bssh='sudo fail2ban-client status sshd'
  alias f2bun='sudo fail2ban-client set sshd unbanip'
  alias f2bban='sudo fail2ban-client set sshd banip'
  alias f2breload='sudo fail2ban-client reload'
  alias f2bls='sudo fail2ban-client banned'
fi

# ---------------------------------------------------------------------------
# SUPERVISOR
# ---------------------------------------------------------------------------
alias svst='sudo supervisorctl status'
alias svrs='sudo supervisorctl restart'
alias svrs-all='sudo supervisorctl restart all'
alias svst-all='sudo supervisorctl status all'
alias svstart='sudo supervisorctl start'
alias svstop='sudo supervisorctl stop'
alias svrload='sudo supervisorctl reread && sudo supervisorctl update'
alias svconf='sudo ${EDITOR:-nvim} /etc/supervisor/supervisord.conf'
alias svconfdir='ls /etc/supervisor/conf.d/'
alias svlog='sudo tail -f /var/log/supervisor/supervisord.log'

# ---------------------------------------------------------------------------
# BENCHMARK
# ---------------------------------------------------------------------------
alias apachebench='ab -n 1000 -c 100'
alias wrk='wrk -t4 -c100 -d30s'
alias siege='siege -c 100 -t 30s'
