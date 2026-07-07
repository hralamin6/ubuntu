#!/usr/bin/env zsh
# =============================================================================
# aliases/nginx.sh, apache.sh, supervisor.sh, systemd.sh, security.sh,
# compression.sh, package.sh — Remaining alias categories
# (Combined for efficiency — split by section headers)
# =============================================================================

# ---------------------------------------------------------------------------
# NGINX
# ---------------------------------------------------------------------------
alias nginx-test='sudo nginx -t'
alias nginx-reload='sudo nginx -t && sudo systemctl reload nginx'
alias nginx-restart='sudo systemctl restart nginx'
alias nginx-stop='sudo systemctl stop nginx'
alias nginx-start='sudo systemctl start nginx'
alias nginx-status='sudo systemctl status nginx'
alias nginx-enable='sudo systemctl enable nginx'
alias nginx-conf='sudo ${EDITOR:-nvim} /etc/nginx/nginx.conf'
alias nginx-sites='ls /etc/nginx/sites-available/'
alias nginx-enabled='ls /etc/nginx/sites-enabled/'
alias nginx-enable-site='sudo ln -sf /etc/nginx/sites-available/$1 /etc/nginx/sites-enabled/'
alias nginx-disable-site='sudo rm -f /etc/nginx/sites-enabled/$1'
alias nginx-log='sudo tail -f /var/log/nginx/access.log'
alias nginx-err='sudo tail -f /var/log/nginx/error.log'
alias nginx-dir='cd /etc/nginx'

# ---------------------------------------------------------------------------
# APACHE
# ---------------------------------------------------------------------------
alias a2test='sudo apache2ctl -t'
alias a2reload='sudo apache2ctl -t && sudo systemctl reload apache2'
alias a2restart='sudo systemctl restart apache2'
alias a2stop='sudo systemctl stop apache2'
alias a2start='sudo systemctl start apache2'
alias a2status='sudo systemctl status apache2'
alias a2enable='sudo a2ensite'
alias a2disable='sudo a2dissite'
alias a2enmod='sudo a2enmod'
alias a2dismod='sudo a2dismod'
alias a2conf='sudo ${EDITOR:-nvim} /etc/apache2/apache2.conf'
alias a2sites='ls /etc/apache2/sites-available/'
alias a2enabled='ls /etc/apache2/sites-enabled/'
alias a2mods='apache2ctl -M 2>/dev/null | sort'
alias a2log='sudo tail -f /var/log/apache2/access.log'
alias a2err='sudo tail -f /var/log/apache2/error.log'
alias a2dir='cd /etc/apache2'
alias a2vhosts='ls /etc/apache2/sites-available/'

# ---------------------------------------------------------------------------
# SYSTEMD (detailed)
# ---------------------------------------------------------------------------
alias sctl='sudo systemctl'
alias sctlst='sudo systemctl status'
alias sctlstart='sudo systemctl start'
alias sctlstop='sudo systemctl stop'
alias sctlrs='sudo systemctl restart'
alias sctlrl='sudo systemctl reload'
alias sctlen='sudo systemctl enable'
alias sctlena='sudo systemctl enable --now'
alias sctldis='sudo systemctl disable'
alias sctldisn='sudo systemctl disable --now'
alias sctlreload='sudo systemctl daemon-reload'
alias sctlmask='sudo systemctl mask'
alias sctlunmask='sudo systemctl unmask'
alias sctllist='systemctl list-units --type=service'
alias sctlfailed='systemctl list-units --failed'
alias sctlboot='systemd-analyze blame | head -20'
alias sctltime='systemd-analyze time'
alias sctlverify='systemd-analyze verify'
alias sctlcat='systemctl cat'
alias sctledit='sudo systemctl edit'
alias sctlprop='systemctl show'
alias sctlisact='systemctl is-active'
alias sctlisenabled='systemctl is-enabled'

# Journal
alias jctl='journalctl'
alias jctlf='journalctl -f'
alias jctlb='journalctl -b'
alias jctlu='journalctl -u'
alias jctluf='journalctl -u -f'
alias jctlp='journalctl -p err'
alias jctlsys='journalctl -k'             # Kernel messages
alias jctltoday='journalctl --since=today'
alias jctlyest='journalctl --since=yesterday'
alias jctlsize='journalctl --disk-usage'
alias jctlvac='sudo journalctl --vacuum-time=7d'

# ---------------------------------------------------------------------------
# SECURITY / SSL
# ---------------------------------------------------------------------------
# OpenSSL
alias ssl-check='openssl s_client -connect'
alias ssl-cert='openssl x509 -noout -text -in'
alias ssl-cert-expiry='openssl x509 -noout -dates -in'
alias ssl-generate-cert='openssl req -new -x509 -days 365 -nodes -out cert.pem -keyout key.pem'
alias ssl-generate-csr='openssl req -new -nodes -out server.csr -newkey rsa:4096 -keyout server.key'
alias ssl-verify='openssl verify -CAfile'
alias ssl-hash='openssl dgst -sha256'
alias ssl-encode='openssl enc -base64'
alias ssl-decode='openssl enc -d -base64'
alias ssl-rsa-info='openssl rsa -noout -text -in'
alias ssl-check-site='echo | openssl s_client -connect'

# GPG
alias gpg-list='gpg --list-keys'
alias gpg-listsec='gpg --list-secret-keys'
alias gpg-import='gpg --import'
alias gpg-export='gpg --armor --export'
alias gpg-exportkey='gpg --armor --export-secret-keys'
alias gpg-sign='gpg --sign'
alias gpg-verify='gpg --verify'
alias gpg-encrypt='gpg --encrypt --armor'
alias gpg-decrypt='gpg --decrypt'
alias gpg-delete='gpg --delete-key'

# Password generation
alias genpasswd='openssl rand -base64 32'
alias genpasswd16='openssl rand -base64 16'
alias genpasswd64='openssl rand -base64 64'
alias genuuid='cat /proc/sys/kernel/random/uuid'
alias gentoken='openssl rand -hex 32'

# Security scanning
alias chkrootkit='sudo chkrootkit'
alias rkhunter='sudo rkhunter --check'

# ---------------------------------------------------------------------------
# COMPRESSION
# ---------------------------------------------------------------------------
alias targz='tar -czvf'
alias untargz='tar -xzvf'
alias tarbz2='tar -cjvf'
alias untarbz2='tar -xjvf'
alias tarxz='tar -cJvf'
alias untarxz='tar -xJvf'
alias tarlist='tar -tvf'
alias zipp='zip -r'
alias unzipp='unzip -v'
alias unzipq='unzip -q'
alias gzip-all='gzip -r'
alias gunzip-all='gunzip -r'
alias bzip2c='bzip2'
alias bunzip2c='bunzip2'
alias xzc='xz -z'
alias xzd='xz -d'
alias zstdc='zstd'
alias zstdd='zstd -d'
alias lzip='lzip -k'
alias zlibcomp='zlib-flate -compress'

# ---------------------------------------------------------------------------
# PACKAGE MANAGEMENT (detailed apt)
# ---------------------------------------------------------------------------
alias update='sudo apt-get update && sudo apt-get upgrade -y'
alias upgrade='sudo apt-get upgrade -y'
alias upgradeable='apt list --upgradable 2>/dev/null'
alias install='sudo apt-get install -y'
alias remove='sudo apt-get remove -y'
alias purge='sudo apt-get purge -y'
alias autoremove='sudo apt-get autoremove --purge -y'
alias search='apt-cache search'
alias show='apt-cache show'
alias policy='apt-cache policy'
alias depends='apt-cache depends'
alias rdepends='apt-cache rdepends'
alias installed='dpkg -l | grep "^ii" | awk "{print \$2}"'
alias installedgrep='dpkg -l | grep'
alias files='dpkg -L'
alias whichpkg='dpkg -S'
alias holds='apt-mark showhold'
alias hold='sudo apt-mark hold'
alias unhold='sudo apt-mark unhold'
alias sources='cat /etc/apt/sources.list'
alias sourcesdir='ls /etc/apt/sources.list.d/'
alias keyrings='ls /usr/share/keyrings/ /etc/apt/trusted.gpg.d/ 2>/dev/null'
alias snap-list='snap list'
alias snap-install='sudo snap install'
alias snap-remove='sudo snap remove'
alias snap-refresh='sudo snap refresh'
alias flatpak-list='flatpak list'
alias flatpak-install='flatpak install'
alias flatpak-remove='flatpak uninstall'
alias flatpak-update='flatpak update'
