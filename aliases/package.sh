#!/usr/bin/env zsh
# aliases/package.sh — Package management
# Main content in nginx.sh PACKAGE section; extras here
alias apt-add-repo='sudo add-apt-repository'
alias apt-keys='apt-key list 2>/dev/null'
alias dpkg-reconfigure='sudo dpkg-reconfigure'
alias deborphan='sudo deborphan | xargs sudo apt-get -y remove --purge'
