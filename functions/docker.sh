#!/usr/bin/env zsh
# =============================================================================
# functions/docker.sh — Docker helper functions (15+)
# =============================================================================

# Clean all stopped containers, dangling images, unused networks, volumes
docker-clean() {
  echo "=== Docker Cleanup ==="
  echo "Stopped containers:"
  docker container prune -f

  echo "Dangling images:"
  docker image prune -f

  echo "Unused networks:"
  docker network prune -f

  echo "Build cache:"
  docker builder prune -f

  echo "Done. Current usage:"
  docker system df
}

# Full Docker cleanup (including unused images)
docker-nuke() {
  echo "WARNING: This will remove ALL unused Docker resources."
  echo -n "Continue? [y/N]: "
  read -r answer
  if [[ "${answer}" =~ ^[Yy]$ ]]; then
    docker system prune --all --volumes -f
    echo "Done."
  fi
}

# Enter a running container with bash or sh
denter() {
  local container="${1:-}"

  if [[ -z "${container}" ]]; then
    if command -v fzf &>/dev/null; then
      container=$(docker ps --format "{{.Names}}" | fzf --prompt="Select container: ")
    else
      docker ps
      echo -n "Container name/ID: "
      read -r container
    fi
  fi

  [[ -z "${container}" ]] && return 1

  docker exec -it "${container}" bash 2>/dev/null || \
  docker exec -it "${container}" sh
}

# Follow logs for a container (with fzf selection)
dlogs() {
  local container="${1:-}"

  if [[ -z "${container}" ]]; then
    if command -v fzf &>/dev/null; then
      container=$(docker ps --format "{{.Names}}" | fzf --prompt="Select container: ")
    else
      docker ps
      echo -n "Container name/ID: "
      read -r container
    fi
  fi

  [[ -z "${container}" ]] && return 1
  docker logs -f --tail=100 "${container}"
}

# Show container resource stats
dstats() {
  docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" "$@"
}

# Build and run a container
docker-build-run() {
  local image_name="${1:-app}"
  local port="${2:-8080}"

  docker build -t "${image_name}" . && \
  docker run -d -p "${port}:${port}" --name "${image_name}" "${image_name}"
  echo "Running at http://localhost:${port}"
}

# Get container IP
docker-ip() {
  local container="${1}"
  if [[ -z "${container}" ]]; then
    echo "Usage: docker-ip <container>" >&2
    return 1
  fi
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${container}"
}

# Port-forward from container to host
docker-port() {
  local container="${1}"
  if [[ -z "${container}" ]]; then
    docker ps --format "{{.Names}}: {{.Ports}}"
  else
    docker port "${container}"
  fi
}

# Run a one-off command in a new container
docker-run-tmp() {
  local image="${1:-ubuntu:22.04}"
  shift
  local cmd="${*:-bash}"
  docker run --rm -it "${image}" "${cmd}"
}

# Push image to registry
docker-push() {
  local image="$1"
  local registry="${2:-}"

  if [[ -n "${registry}" ]]; then
    docker tag "${image}" "${registry}/${image}"
    docker push "${registry}/${image}"
  else
    docker push "${image}"
  fi
}

# Show Docker Compose status in current directory
dstatus() {
  if [[ -f "docker-compose.yml" || -f "compose.yml" || -f "docker-compose.yaml" ]]; then
    docker compose ps 2>/dev/null || docker-compose ps
  else
    echo "No docker-compose.yml found in $(pwd)" >&2
  fi
}

# Restart a specific service in compose
drestart() {
  local service="${1:-}"
  if [[ -n "${service}" ]]; then
    docker compose restart "${service}" 2>/dev/null || \
    docker-compose restart "${service}"
  else
    docker compose restart 2>/dev/null || docker-compose restart
  fi
}

# Shell into a docker compose service
dshell() {
  local service="${1:-app}"
  docker compose exec "${service}" bash 2>/dev/null || \
  docker compose exec "${service}" sh 2>/dev/null || \
  docker-compose exec "${service}" bash 2>/dev/null || \
  docker-compose exec "${service}" sh
}

# Docker compose up with build
dupbuild() {
  docker compose up -d --build 2>/dev/null || \
  docker-compose up -d --build
}

# Show running containers in compact format
dlist() {
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
}

# Copy file from container to host
docker-copy-from() {
  local container="$1"
  local src="$2"
  local dest="${3:-.}"
  docker cp "${container}:${src}" "${dest}"
}

# Copy file from host to container
docker-copy-to() {
  local src="$1"
  local container="$2"
  local dest="$3"
  docker cp "${src}" "${container}:${dest}"
}
