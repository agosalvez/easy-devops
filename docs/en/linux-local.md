# Ubuntu local installation

This journey supports Ubuntu 22.04 and 24.04 and creates a single-node Swarm
available at `http://portainer.localhost`.

## Requirements

- A supported Ubuntu release.
- A normal user with `sudo` access.
- Internet access.
- TCP port 80 available.

## Installation

```bash
git clone https://github.com/agosalvez/easy-devops.git
cd easy-devops
chmod +x installers/linux-local.sh scripts/linux/manage.sh
./installers/linux-local.sh
```

The installer shows its plan, installs Docker Engine from Docker's official apt
repository when needed, initializes Swarm, creates the proxy overlay network,
and deploys Traefik and Portainer.

If your user was newly added to the `docker` group, log out and back in before
running Docker without `sudo`.

## Validation

```bash
docker node ls
docker stack services easy-devops-traefik
docker stack services easy-devops-portainer
./scripts/linux/manage.sh status
curl -I -H 'Host: portainer.localhost' http://127.0.0.1
```

Expected: one manager, healthy service replicas, and an HTTP response from
Traefik.

## Operations

```bash
./scripts/linux/manage.sh start
./scripts/linux/manage.sh stop
./scripts/linux/manage.sh backup
./scripts/linux/manage.sh update
./scripts/linux/manage.sh uninstall
```

Backups are timestamped archives in `backups/`. Stop and uninstall preserve
the Portainer volume.

## Network access

The default hostname is intended for the same machine. To access the lab from
another device, map the chosen hostname to the Ubuntu machine's LAN address and
ensure the firewall permits TCP port 80.

