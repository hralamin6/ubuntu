#!/usr/bin/env zsh
# aliases/supervisor.sh — Supervisor process control
# Main aliases in monitoring.sh; extras here
alias svconf-new='sudo ${EDITOR:-nvim} /etc/supervisor/conf.d/'
alias svlist='sudo supervisorctl status all | awk "{print \$1}"'
alias svpid='sudo supervisorctl pid all'
