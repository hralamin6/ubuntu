# VPS সার্ভারে CLI Bootstrap ব্যবহারের সম্পূর্ণ গাইড

> **লক্ষ্য:** Ubuntu/Debian VPS-এ CLI Bootstrap ইনস্টল করে একটি প্রফেশনাল ডেভেলপমেন্ট পরিবেশ তৈরি করা।

---

## ১. VPS-এ প্রথমবার সংযোগ

```bash
# SSH দিয়ে VPS-এ লগইন করুন
ssh root@your-server-ip

# অথবা কাস্টম পোর্ট ব্যবহার করলে
ssh -p 2222 root@your-server-ip

# SSH key দিয়ে লগইন (recommended)
ssh -i ~/.ssh/id_ed25519 root@your-server-ip
```

---

## ২. প্রথমে সিস্টেম আপডেট করুন

```bash
apt-get update && apt-get upgrade -y
```

---

## ৩. git ইনস্টল করুন (না থাকলে)

```bash
apt-get install -y git curl
```

---

## ৪. CLI Bootstrap ডাউনলোড করুন

```bash
# হোম ডিরেক্টরিতে যান
cd ~

# রিপোজিটরি ক্লোন করুন (আপনার পাথ অনুযায়ী পরিবর্তন করুন)
git clone /home/hralamin/www/ubuntu/cli-bootstrap ~/cli-bootstrap

# অথবা GitHub থেকে (যদি push করা থাকে)
# git clone https://github.com/yourname/cli-bootstrap.git ~/cli-bootstrap

cd ~/cli-bootstrap
```

---

## ৫. ইনস্টল করুন

```bash
# root হিসেবে ইনস্টল
bash install.sh

# অথবা verbose মোডে (বিস্তারিত লগ দেখতে)
bash install.sh --verbose

# non-interactive মোডে (কোনো প্রশ্ন ছাড়া — CI/CD-র জন্য)
bash install.sh --non-interactive
```

> ইনস্টলেশন সম্পন্ন হতে ৫–১৫ মিনিট সময় লাগতে পারে।

---

## ৬. ইনস্টলেশনের পর

```bash
# নতুন shell লোড করুন
exec zsh

# সব কিছু ঠিকঠাক কিনা চেক করুন
bash ~/cli-bootstrap/doctor.sh
```

---

## ৭. মূল কমান্ডসমূহ

### ফাইল নেভিগেশন

```bash
ll          # বিস্তারিত ফাইল লিস্ট (eza দিয়ে)
lt          # ট্রি ভিউ
la          # hidden ফাইলসহ
..          # এক ডিরেক্টরি উপরে
...         # দুই ডিরেক্টরি উপরে

# স্মার্ট cd (zoxide)
cd projects     # সরাসরি যাওয়া
zi              # fzf দিয়ে interactive cd
```

### ফাইল সার্চ ও দেখা

```bash
cat file.php    # syntax highlighting সহ (bat)
rg "keyword"    # ripgrep দিয়ে সার্চ
ff "*.php"      # fd দিয়ে ফাইল খোঁজা

# FZF shortcuts
Ctrl+R          # history সার্চ
Ctrl+T          # ফাইল সার্চ
Alt+C           # ডিরেক্টরি জাম্প
```

### Git কমান্ড

```bash
gs              # git status (short)
gl              # সুন্দর git log
ga              # git add
gcm "message"   # git commit -m
gps             # git push
gpl             # git pull
lg              # lazygit (TUI)
gqc "message"   # git add --all && commit
git-standup     # আজকের commits দেখুন
git-stats       # repo statistics
```

### Docker কমান্ড

```bash
dkps            # docker ps
dklf            # docker logs -f
denter          # container-এ enter করুন (fzf দিয়ে select)
dlogs           # logs follow করুন
dup             # docker compose up -d
ddown           # docker compose down
dupbuild        # docker compose up --build -d
docker-clean    # unused resources মুছুন
```

### Laravel/PHP কমান্ড

```bash
pa              # php artisan
pas             # php artisan serve
pam             # php artisan migrate
pamfs           # migrate:fresh --seed
tin             # php artisan tinker
pa rl           # route:list
fresh           # migrate:fresh --seed (shortcut)
laraclr         # সব cache clear
larainstall     # fresh install (composer + migrate + seed)

# Composer
ci              # composer install
cu              # composer update
cr package      # composer require
```

### Nginx/Apache ম্যানেজমেন্ট

```bash
nginx-test      # nginx config test
nginx-reload    # reload nginx
nginx-log       # access log follow
nginx-err       # error log follow
nginx-status    # service status

a2test          # apache config test
a2reload        # reload apache
a2enable site   # site enable
```

### Systemd সার্ভিস

```bash
ssc nginx       # systemctl status nginx
sscst nginx     # start
sscsp nginx     # stop
sscrs nginx     # restart
sscea nginx     # enable --now
jctlf           # journalctl -f (live logs)
jctlu nginx     # nginx logs
jctlb           # current boot logs
```

### সিস্টেম মনিটরিং

```bash
btop            # beautiful resource monitor
sysinfo         # সম্পূর্ণ সিস্টেম তথ্য
mem-top         # top memory consumers
cpu-top         # top CPU consumers
ports           # সব listening ports
disk-report     # disk usage report
boot-analysis   # boot time analysis
```

### নেটওয়ার্ক

```bash
myip            # public + local IP
killport 3000   # পোর্ট 3000 বন্ধ করুন
findport 80     # কোন process পোর্ট 80 ব্যবহার করছে
dns-lookup example.com   # DNS records
ssl-expiry example.com   # SSL certificate expiry
is-up https://site.com   # সাইট alive কিনা চেক
```

---

## ৮. Tmux — Terminal Multiplexer

VPS-এ কাজ করার সময় Tmux অবশ্যই ব্যবহার করুন। connection বিচ্ছিন্ন হলেও session বজায় থাকে।

```bash
# নতুন session শুরু
tmux new -s mysession

# session-এ ফিরে আসুন (reconnect-এর পর)
tmux attach -t mysession

# সব session দেখুন
tmux ls
```

### Tmux কী-বাইন্ডিং (Prefix = Ctrl+b)

| কী | কাজ |
|---|---|
| `Ctrl+b |` | ভার্টিক্যালি split করুন |
| `Ctrl+b -` | হরিজন্টালি split করুন |
| `Ctrl+b h/j/k/l` | pane-এ navigate করুন |
| `Ctrl+b c` | নতুন window |
| `Ctrl+b n` | পরের window |
| `Ctrl+b z` | pane zoom করুন |
| `Ctrl+b d` | detach (session চলতে থাকবে) |
| `Ctrl+b g` | lazygit popup |

---

## ৯. Starship Prompt কাস্টমাইজ

```bash
# theme পরিবর্তন
starshipconf   # ~/.config/starship.toml edit

# minimal theme
cp ~/cli-bootstrap/themes/minimal.toml ~/.config/starship.toml

# powerline theme
cp ~/cli-bootstrap/themes/powerline.toml ~/.config/starship.toml
```

---

## ১০. নিজস্ব কাস্টমাইজেশন

### নিজের aliases যোগ করুন

```bash
cat >> ~/.cli-bootstrap/aliases/my.sh << 'EOF'
# আমার custom aliases
alias mysite='cd /var/www/myapp && git status'
alias devlog='tail -f /var/www/myapp/storage/logs/laravel.log'
EOF

# পরিবর্তন কার্যকর করুন
exec zsh
```

### নিজের functions যোগ করুন

```bash
cat >> ~/.cli-bootstrap/functions/my.sh << 'EOF'
# Laravel project quick start
myproject() {
  cd /var/www/"$1"
  git status
  php artisan serve
}
EOF
exec zsh
```

### local overrides (.zshrc.local)

```bash
cat >> ~/.zshrc.local << 'EOF'
# VPS-নির্দিষ্ট সেটিংস
export PROJECTS_DIR="/var/www"
export EDITOR="nano"   # nvim না থাকলে
alias reload='exec zsh'
EOF
```

---

## ১১. আপডেট করুন

```bash
cd ~/cli-bootstrap

# প্রথমে নতুন কোড pull করুন
git pull

# তারপর আপডেট চালান
bash update.sh
```

---

## ১২. ডায়াগনস্টিক চালান

```bash
# সব কিছু চেক করুন
bash ~/cli-bootstrap/doctor.sh

# সমস্যা auto-fix করুন
bash ~/cli-bootstrap/doctor.sh --fix
```

**doctor.sh যা চেক করে:**
- Required binaries (zsh, git, curl, fzf...)
- Recommended tools (starship, bat, eza, delta...)
- .zshrc syntax
- Plugin installation
- Starship config
- Git user config
- Broken symlinks

---

## ১৩. ব্যাকআপ ও রিস্টোর

```bash
# ম্যানুয়াল ব্যাকআপ
bash ~/cli-bootstrap/backup.sh backup

# সব ব্যাকআপ দেখুন
bash ~/cli-bootstrap/backup.sh list

# রিস্টোর (সর্বশেষ ব্যাকআপ থেকে)
bash ~/cli-bootstrap/restore.sh

# পুরোনো ব্যাকআপ মুছুন (শেষ ৫টি রাখুন)
bash ~/cli-bootstrap/backup.sh purge 5
```

---

## ১৪. আনইনস্টল করুন

```bash
bash ~/cli-bootstrap/uninstall.sh
```

এটি আপনার আগের dotfiles ব্যাকআপ থেকে রিস্টোর করবে।

---

## ১৫. সাধারণ সমস্যা ও সমাধান

### সমস্যা: Zsh কাজ করছে না

```bash
# syntax চেক
zsh -n ~/.zshrc

# zsh ছাড়া শুরু
zsh --no-rcs

# আবার doctor চালান
bash ~/cli-bootstrap/doctor.sh --fix
```

### সমস্যা: Starship prompt দেখা যাচ্ছে না

```bash
which starship
starship --version

# পুনরায় ইনস্টল
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
```

### সমস্যা: Shell শুরু হতে বেশি সময় লাগছে

```bash
# startup সময় মাপুন
time zsh -i -c exit

# ~/.zshrc-এর শুরুতে এটি যোগ করুন profiling-এর জন্য
# zmodload zsh/zprof
# শেষে: zprof
```

### সমস্যা: `bat` কাজ করছে না

```bash
# Ubuntu/Debian-এ bat হয়তো batcat নামে আছে
which batcat
ln -sf $(which batcat) ~/.local/bin/bat
```

### সমস্যা: `fd` কাজ করছে না

```bash
# Ubuntu-তে fd হয় fdfind নামে
which fdfind
ln -sf $(which fdfind) ~/.local/bin/fd
```

---

## ১৬. দরকারী Shell Functions

```bash
# ডিরেক্টরি তৈরি করে সেখানে যান
mkcd myproject

# যেকোনো archive extract করুন
extract archive.tar.gz
extract file.zip

# HTTP server শুরু করুন (current directory)
serve 8080

# আবহাওয়া দেখুন
weather Dhaka

# পাসওয়ার্ড তৈরি করুন
genpasswd 32

# JSON সুন্দর করুন
json-pretty file.json
echo '{"key":"value"}' | json-pretty

# JWT decode করুন
jwt-decode eyJhbGci...

# বড় ফাইল খুঁজুন
find-large-files . 50M

# পোর্ট বন্ধ করুন
killport 3000

# DNS propagation চেক করুন
dns-propagation example.com

# SSL মেয়াদ দেখুন
ssl-expiry example.com 443
```

---

## ১৭. Laravel VPS Deployment Workflow

```bash
# ১. প্রজেক্ট directory-তে যান
cd /var/www/mylaravel

# ২. কোড pull করুন
gpl    # git pull

# ৩. dependencies ইনস্টল
ci     # composer install --no-dev

# ৪. caches clear
laraclr

# ৫. production optimize
laravel-optimize

# ৬. database migrate
pam    # php artisan migrate

# ৭. nginx reload
nginx-reload

# ৮. logs monitor করুন
logs   # tail -f storage/logs/laravel.log
```

---

## ১৮. Docker Workflow VPS-এ

```bash
# ১. প্রজেক্ট শুরু করুন
dup         # docker compose up -d

# ২. status দেখুন
dps         # docker compose ps
dlist       # all containers

# ৩. logs দেখুন
dlogs       # follow logs (fzf দিয়ে container select)
dklf nginx  # নির্দিষ্ট container

# ৪. container-এ ঢুকুন
denter      # fzf দিয়ে select করুন
dshell app  # compose service

# ৫. cleanup
docker-clean   # unused resources
```

---

## ১৯. Security Tips

```bash
# ফাইল permissions ঠিক করুন
fix-permissions /var/www/myapp
fix-web-permissions /var/www/myapp www-data

# SSL certificate check
ssl-expiry yourdomain.com

# Open ports দেখুন
ports

# Failed login attempts
sudo lastb | head -20

# Firewall status
ufwst
```

---

## ২০. Quick Reference Card

| কাজ | কমান্ড |
|---|---|
| ফাইল দেখুন | `ll`, `lt`, `la` |
| ফাইল search | `rg "text"`, `ff "*.php"` |
| History search | `Ctrl+R` |
| Directory jump | `zi` |
| Git status | `gs` |
| Git log | `gl` |
| Git TUI | `lg` |
| Docker status | `dlist` |
| Container logs | `dlogs` |
| Container shell | `denter` |
| Artisan | `pa`, `pa migrate` |
| Nginx reload | `nginx-reload` |
| Service status | `scs nginx` |
| Live logs | `jctlf` |
| Resource monitor | `btop` |
| System info | `sysinfo` |
| My IP | `myip` |
| Kill port | `killport 3000` |
| Password gen | `genpasswd` |
| Extract archive | `extract file.tar.gz` |
| Weather | `weather Dhaka` |

---

> **টিপস:** যেকোনো alias খুঁজে পেতে `alias | grep keyword` অথবা `Ctrl+R` দিয়ে history সার্চ করুন।
>
> ডকুমেন্টেশন: `README.md` — সম্পূর্ণ বাংলায় এই ফাইলটি।
