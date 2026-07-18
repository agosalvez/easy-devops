#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOCKER=docker
docker info >/dev/null 2>&1 || DOCKER="sudo docker"
[[ -f "$ROOT/.env" ]] || { echo "Missing .env; run an installer first." >&2; exit 2; }
set -a; . "$ROOT/.env"; set +a

case "${1:-status}" in
  status)
    $DOCKER node ls
    $DOCKER stack services easy-devops-traefik
    $DOCKER stack services easy-devops-portainer
    ;;
  start)
    $DOCKER network inspect easy-devops-proxy >/dev/null 2>&1 || $DOCKER network create --driver overlay --attachable easy-devops-proxy
    $DOCKER stack deploy -c "$ROOT/stacks/$EASY_DEVOPS_MODE/traefik.yml" easy-devops-traefik
    $DOCKER stack deploy -c "$ROOT/stacks/$EASY_DEVOPS_MODE/portainer.yml" easy-devops-portainer
    ;;
  stop)
    $DOCKER stack rm easy-devops-portainer
    $DOCKER stack rm easy-devops-traefik
    ;;
  backup)
    mkdir -p "$ROOT/backups"
    stamp="$(date -u +%Y%m%dT%H%M%SZ)"
    $DOCKER run --rm -v easy-devops-portainer_portainer-data:/data:ro -v "$ROOT/backups:/backup" alpine:3.20 tar czf "/backup/portainer-$stamp.tgz" -C /data .
    echo "Backup created: backups/portainer-$stamp.tgz"
    ;;
  update)
    "$0" backup
    $DOCKER pull "$TRAEFIK_IMAGE"
    $DOCKER pull "$PORTAINER_IMAGE"
    $DOCKER pull "$PORTAINER_AGENT_IMAGE"
    "$0" start
    ;;
  uninstall)
    read -r -p "Remove Easy DevOps stacks but keep data? [y/N] " answer
    [[ "$answer" =~ ^[Yy]$ ]] || exit 0
    "$0" stop
    ;;
  *) echo "Usage: $0 {status|start|stop|backup|update|uninstall}" >&2; exit 2 ;;
esac

