#!/usr/bin/env zsh
# =============================================================================
# aliases/networking.sh — Network tools aliases
# =============================================================================

# ---------------------------------------------------------------------------
# NETWORK INFO
# ---------------------------------------------------------------------------
alias myip='curl -fsSL https://ifconfig.me && echo'
alias myipv6='curl -fsSL https://ifconfig.co && echo'
alias myips='ip addr show | grep "inet " | awk "{print \$2}"'
alias localip='ip route get 1 | awk "{print \$NF; exit}"'

# Use doggo if available, fallback to dig
if command -v doggo &>/dev/null; then
  alias dig='doggo'
  alias nslookup='doggo'
else
  alias dig='dig +short'
  alias digg='dig +noall +answer +additional'
fi

alias ping='ping -c 5'
alias pingg='ping -c 5 8.8.8.8'
alias mtr='mtr --report --report-cycles=10'
alias traceroute='traceroute -I'
alias tracert='traceroute -I'

# ---------------------------------------------------------------------------
# PORT SCANNING / CONNECTIONS
# ---------------------------------------------------------------------------
alias ports='ss -tulpn'
alias portsall='ss -atupn'
alias portsl='ss -tulpn | grep LISTEN'
alias portsest='ss -tupn | grep ESTABLISHED'
alias netstat='ss -tupn'
alias lsof-net='lsof -i -P -n'
alias openports='ss -tulpn | grep -v "127.0.0.1" | grep LISTEN'

# Using nmap
alias portscan='nmap -sV --open'
alias hostscan='nmap -sP'

# ---------------------------------------------------------------------------
# HTTP TESTING (XH — modern curl)
# ---------------------------------------------------------------------------
if command -v xh &>/dev/null; then
  alias http='xh'
  alias https='xh --https'
  alias httpget='xh GET'
  alias httppost='xh POST'
  alias httpput='xh PUT'
  alias httpdel='xh DELETE'
  alias httpjson='xh --json'
  alias httpheaders='xh --headers'
elif command -v curl &>/dev/null; then
  alias httpget='curl -fsSL'
  alias httpheaders='curl -I'
  alias httppost='curl -X POST'
fi

alias curltime='curl -o /dev/null -s -w "\nDNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n"'
alias curltest='curl -I --max-time 5'
alias curljson='curl -H "Content-Type: application/json"'

# ---------------------------------------------------------------------------
# FIREWALL
# ---------------------------------------------------------------------------
alias ufw='sudo ufw'
alias ufwst='sudo ufw status verbose'
alias ufwl='sudo ufw status numbered'
alias ufwallow='sudo ufw allow'
alias ufwdeny='sudo ufw deny'
alias ufwdelete='sudo ufw delete'
alias ufwen='sudo ufw enable'
alias ufwdis='sudo ufw disable'
alias ufwreset='sudo ufw reset'
alias iptables='sudo iptables'
alias iptl='sudo iptables -L -n -v'

# ---------------------------------------------------------------------------
# SSH
# ---------------------------------------------------------------------------
alias ssh='ssh -o StrictHostKeyChecking=ask -o UserKnownHostsFile=~/.ssh/known_hosts'
alias sshr='ssh -o StrictHostKeyChecking=no'      # No host check (use carefully)
alias ssht='ssh -o ConnectTimeout=5'               # With timeout
alias sshcp='ssh-copy-id'
alias sshkeygen='ssh-keygen -t ed25519 -C "$(git config user.email)"'
alias sshkeygenrsa='ssh-keygen -t rsa -b 4096 -C "$(git config user.email)"'
alias sshls='ls -la ~/.ssh/'
alias sshconf='cat ~/.ssh/config'
alias sshadd='ssh-add'
alias sshaddall='ssh-add ~/.ssh/*.pem ~/.ssh/id_* 2>/dev/null'
alias sshagent='eval "$(ssh-agent -s)"'
alias sshfp='ssh-keygen -lf'                       # Fingerprint
alias sshpubkey='cat ~/.ssh/id_ed25519.pub 2>/dev/null || cat ~/.ssh/id_rsa.pub 2>/dev/null'

# SCP shortcuts
alias scpget='scp -r'
alias scpput='scp -r'
alias scprecursive='scp -r'

# ---------------------------------------------------------------------------
# DNS
# ---------------------------------------------------------------------------
alias flushDNS='sudo systemd-resolve --flush-caches && sudo systemctl restart systemd-resolved'
alias dnsstatus='systemd-resolve --statistics'
alias dnsservers='cat /etc/resolv.conf'
alias nsflush='sudo resolvectl flush-caches'

# ---------------------------------------------------------------------------
# NETWORK INTERFACES
# ---------------------------------------------------------------------------
alias ifconfig='ip addr'
alias ipaddr='ip addr show'
alias iproute='ip route show'
alias iplink='ip link show'
alias ipneigh='ip neigh show'
alias ipns='ip netns'
alias iwconfig='iwctl station list 2>/dev/null || iwconfig'
alias wifi='nmcli device wifi list'
alias wificonn='nmcli device wifi connect'

# ---------------------------------------------------------------------------
# BANDWIDTH / MONITORING
# ---------------------------------------------------------------------------
alias iftop='sudo iftop -i eth0'
alias nethogs='sudo nethogs'
alias bmon='bmon'
alias nload='nload'
alias vnstat='vnstat -l'

# ---------------------------------------------------------------------------
# PROXY
# ---------------------------------------------------------------------------
alias setproxy='export http_proxy=http://localhost:8080 && export https_proxy=http://localhost:8080'
alias unsetproxy='unset http_proxy && unset https_proxy && unset HTTP_PROXY && unset HTTPS_PROXY'
alias proxycheck='env | grep -i proxy'

# ---------------------------------------------------------------------------
# SSHFS / MOUNT
# ---------------------------------------------------------------------------
alias sshfs='sshfs -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3'
alias fusermount='fusermount -u'
