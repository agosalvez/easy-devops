#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/shell/common.sh
. "$ROOT/lib/shell/common.sh"

require_ubuntu || die 11 "Ubuntu 22.04 or 24.04 is required"
[[ $EUID -ne 0 ]] || die 12 "Run as a normal sudo-enabled user, not root"

log_info "Easy DevOps will install Docker Engine, initialize one-node Swarm, and deploy Traefik + Portainer."
confirm "Continue?" || exit 0

if ! command_exists docker; then
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  . /etc/os-release
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"
fi

DOCKER="docker"
docker info >/dev/null 2>&1 || DOCKER="sudo docker"
$DOCKER info >/dev/null
$DOCKER info --format '{{.Swarm.LocalNodeState}}' | grep -q active || $DOCKER swarm init
$DOCKER network inspect easy-devops-proxy >/dev/null 2>&1 || $DOCKER network create --driver overlay --attachable easy-devops-proxy

cp -n "$ROOT/.env.example" "$ROOT/.env"
set -a; . "$ROOT/.env"; set +a
export EASY_DEVOPS_MODE=local EASY_DEVOPS_DOMAIN=portainer.localhost
$DOCKER stack deploy -c "$ROOT/stacks/local/traefik.yml" easy-devops-traefik
$DOCKER stack deploy -c "$ROOT/stacks/local/portainer.yml" easy-devops-portainer

log_success "Deployment submitted."
log_info "Wait about one minute, then open http://portainer.localhost"
log_info "Check status with: ./scripts/linux/manage.sh status"

