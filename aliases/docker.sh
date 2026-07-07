#!/usr/bin/env zsh
# =============================================================================
# aliases/docker.sh — Docker and Docker Compose aliases
# =============================================================================

# ---------------------------------------------------------------------------
# DOCKER
# ---------------------------------------------------------------------------
alias dk='docker'
alias dkb='docker build'
alias dkbt='docker build --tag'
alias dkbf='docker build --file'
alias dkr='docker run'
alias dkri='docker run -it'
alias dkrd='docker run -d'
alias dkrm='docker run --rm'
alias dkrmi='docker run --rm -it'
alias dkrv='docker run -v "$(pwd):/app"'
alias dkex='docker exec'
alias dkexi='docker exec -it'
alias dkexb='docker exec -it $(docker ps -q | head -1) bash'
alias dkexs='docker exec -it $(docker ps -q | head -1) sh'
alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dkpsl='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'
alias dkst='docker stats'
alias dksta='docker stats --all'
alias dkl='docker logs'
alias dklf='docker logs -f'
alias dklt='docker logs --tail=100'
alias dklft='docker logs -f --tail=100'
alias dkins='docker inspect'
alias dktop='docker top'
alias dkpull='docker pull'
alias dkpush='docker push'
alias dktag='docker tag'
alias dklogin='docker login'
alias dklogout='docker logout'

# Container management
alias dkstart='docker start'
alias dkstop='docker stop'
alias dkrs='docker restart'
alias dkrm='docker rm'
alias dkrmf='docker rm -f'
alias dkrma='docker rm $(docker ps -aq)'         # Remove all stopped
alias dkrmaf='docker rm -f $(docker ps -aq)'     # Force remove all
alias dkkill='docker kill'

# Image management
alias dki='docker images'
alias dkia='docker images -a'
alias dkrmi='docker rmi'
alias dkrmif='docker rmi -f'
alias dkrmia='docker rmi $(docker images -q)'    # Remove all images
alias dkrmid='docker image prune'                 # Remove dangling images
alias dkrmida='docker image prune -a'             # Remove all unused images

# Volume management
alias dkv='docker volume'
alias dkvls='docker volume ls'
alias dkvcr='docker volume create'
alias dkvrm='docker volume rm'
alias dkvprune='docker volume prune'

# Network management
alias dkn='docker network'
alias dknls='docker network ls'
alias dkncr='docker network create'
alias dknrm='docker network rm'
alias dkninspect='docker network inspect'

# System
alias dkprune='docker system prune'
alias dkprunea='docker system prune --all --volumes'
alias dkinfo='docker system info'
alias dkdf='docker system df'
alias dkevents='docker events'

# ---------------------------------------------------------------------------
# DOCKER COMPOSE
# ---------------------------------------------------------------------------
# Support both 'docker compose' (v2) and 'docker-compose' (v1)
if docker compose version &>/dev/null 2>&1; then
  alias dc='docker compose'
else
  alias dc='docker-compose'
fi

alias dcu='dc up'
alias dcud='dc up -d'
alias dcd='dc down'
alias dcr='dc restart'
alias dcrs='dc down && dc up -d'       # Full restart
alias dcl='dc logs'
alias dclf='dc logs -f'
alias dclt='dc logs --tail=100'
alias dclft='dc logs -f --tail=100'
alias dcps='dc ps'
alias dcex='dc exec'
alias dcrun='dc run --rm'
alias dcbuild='dc build'
alias dcbuildn='dc build --no-cache'
alias dcpull='dc pull'
alias dcpush='dc push'
alias dcstop='dc stop'
alias dcstart='dc start'
alias dcpause='dc pause'
alias dcunpause='dc unpause'
alias dckill='dc kill'
alias dcrm='dc rm'
alias dcconfig='dc config'
alias dcscale='dc scale'
alias dctop='dc top'
alias dcimages='dc images'
alias dcvalidate='dc config --quiet && echo "docker-compose.yml is valid"'

# Short project-level shortcuts
alias dps='docker compose ps 2>/dev/null || docker-compose ps'
alias dlogs='docker compose logs -f 2>/dev/null || docker-compose logs -f'
alias dup='docker compose up -d 2>/dev/null || docker-compose up -d'
alias ddown='docker compose down 2>/dev/null || docker-compose down'

# ---------------------------------------------------------------------------
# DOCKER SHORTCUTS WITH FZF
# ---------------------------------------------------------------------------
alias dkfzf='docker ps | fzf --header-lines=1 | awk "{print \$1}"'
alias dklog='docker logs -f "$(docker ps | fzf --header-lines=1 | awk "{print \$1}")"'
alias dksh='docker exec -it "$(docker ps | fzf --header-lines=1 | awk "{print \$1}")" sh'
alias dkbash='docker exec -it "$(docker ps | fzf --header-lines=1 | awk "{print \$1}")" bash'
