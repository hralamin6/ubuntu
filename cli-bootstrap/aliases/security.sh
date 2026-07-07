#!/usr/bin/env zsh
# aliases/security.sh — Security aliases (sourced separately for clarity)
# See nginx.sh for SSL/GPG — these are extras

alias chkperms='find . -perm /o+w 2>/dev/null'
alias chkSUID='find / -perm -4000 -type f 2>/dev/null'
alias chkSGID='find / -perm -2000 -type f 2>/dev/null'
alias world-writable='find / -perm -0002 -not -type l 2>/dev/null'
alias audit-ssh='sudo auditd && sudo auditctl -a always,exit -F arch=b64 -S all -k ssh'
alias nmap-quick='nmap -T4 -F'
alias nmap-full='nmap -T4 -A -v'
alias nmap-vuln='nmap --script vuln'
alias lynis='sudo lynis audit system'
