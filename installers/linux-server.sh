#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/shell/common.sh
. "$ROOT/lib/shell/common.sh"

require_ubuntu || die 11 "Ubuntu Server 22.04 or 24.04 is required"
[[ $EUID -ne 0 ]] || die 12 "Run as a normal sudo-enabled user, not root"
read -r -p "Portainer domain (for example portainer.example.com): " DOMAIN
read -r -p "Let's Encrypt email: " EMAIL
[[ "$DOMAIN" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]] || die 20 "Invalid domain"
[[ "$EMAIL" =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]] || die 21 "Invalid email"

log_info "Easy DevOps will install Docker, initialize Swarm, and expose Portainer at https://$DOMAIN."
confirm "Continue?" || exit 0
command_exists curl || { sudo apt-get update; sudo apt-get install -y curl ca-certificates; }
DNS_IP="$(getent ahostsv4 "$DOMAIN" | awk 'NR==1 {print $1}')"
PUBLIC_IP="$(curl -fsS https://api.ipify.org)"
[[ "$DNS_IP" == "$PUBLIC_IP" ]] || die 22 "DNS resolves to '$DNS_IP', but this server is '$PUBLIC_IP'"

if ! command_exists docker; then
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

DOCKER=docker
docker info >/dev/null 2>&1 || DOCKER="sudo docker"
$DOCKER info --format '{{.Swarm.LocalNodeState}}' | grep -q active || $DOCKER swarm init --advertise-addr "$PUBLIC_IP"
$DOCKER network inspect easy-devops-proxy >/dev/null 2>&1 || $DOCKER network create --driver overlay --attachable easy-devops-proxy

cp -n "$ROOT/.env.example" "$ROOT/.env"
export TRAEFIK_IMAGE=traefik:v3.7 PORTAINER_IMAGE=portainer/portainer-ce:lts PORTAINER_AGENT_IMAGE=portainer/agent:lts
export EASY_DEVOPS_MODE=server EASY_DEVOPS_DOMAIN="$DOMAIN" EASY_DEVOPS_ACME_EMAIL="$EMAIL"
{
  printf 'EASY_DEVOPS_MODE=server\nEASY_DEVOPS_DOMAIN=%s\nEASY_DEVOPS_ACME_EMAIL=%s\n' "$DOMAIN" "$EMAIL"
  printf 'TRAEFIK_IMAGE=%s\nPORTAINER_IMAGE=%s\nPORTAINER_AGENT_IMAGE=%s\n' "$TRAEFIK_IMAGE" "$PORTAINER_IMAGE" "$PORTAINER_AGENT_IMAGE"
} >"$ROOT/.env"
chmod 600 "$ROOT/.env"
$DOCKER stack deploy -c "$ROOT/stacks/server/traefik.yml" easy-devops-traefik
$DOCKER stack deploy -c "$ROOT/stacks/server/portainer.yml" easy-devops-portainer
log_success "Deployment submitted. Open https://$DOMAIN after certificate issuance."
