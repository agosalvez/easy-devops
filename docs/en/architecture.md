# Architecture

## Request flow

```text
Client
  |
  | local HTTP or server HTTPS
  v
Traefik (manager)
  |
  | easy-devops-proxy overlay
  v
Portainer Server (manager)
  |
  | encrypted Agent protocol on the private agent network
  v
Portainer Agent (global) -> Docker socket and volume metadata
```

Traefik discovers routing labels from Swarm services. For that reason all
Portainer routing labels are under `deploy.labels`. Both Traefik and Portainer
Server are constrained to managers; the Agent runs globally on Linux nodes.

## Networks and persistence

- `easy-devops-proxy` is an external attachable overlay shared by stacks.
- The Portainer stack creates a private Agent overlay network.
- `portainer-data` stores Portainer state.
- The server Traefik stack stores ACME data in a Docker volume.
- Generated configuration and backups are ignored by Git.

## Security boundaries

Server mode exposes only ports 80 and 443. Portainer's internal port 9000 is
reachable only through Traefik. The insecure Traefik dashboard is disabled.
Mounting the Docker socket remains privileged and is documented as a trusted
administrator boundary.

## Scope

Version 1 targets one manager. Additional workers can join later, but multiple
managers, quorum design, external storage, disaster recovery, and zero-downtime
upgrades require a separate high-availability architecture.

