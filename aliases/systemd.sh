#!/usr/bin/env zsh  
# aliases/systemd.sh — Systemd aliases
# Main content in nginx.sh SYSTEMD section; extra user-level aliases here
alias sctl-user='systemctl --user'
alias sctl-user-start='systemctl --user start'
alias sctl-user-stop='systemctl --user stop'
alias sctl-user-status='systemctl --user status'
alias sctl-user-enable='systemctl --user enable'
alias sctl-user-list='systemctl --user list-units'
alias loginctl-list='loginctl list-sessions'
alias loginctl-user='loginctl show-user'
