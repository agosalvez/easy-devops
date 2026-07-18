# Easy DevOps

[![Quality](https://github.com/agosalvez/easy-devops/actions/workflows/quality.yml/badge.svg)](https://github.com/agosalvez/easy-devops/actions/workflows/quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker Swarm](https://img.shields.io/badge/Docker-Swarm-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/engine/swarm/)

> Build a local or self-hosted Docker Swarm with Traefik and Portainer through a transparent guided installer.

[Español](README.es.md) · [Security](SECURITY.md) · [Design](docs/superpowers/specs/2026-07-18-easy-devops-v1-design.md)

Easy DevOps is an educational, security-conscious path from an empty machine to a manageable single-node Docker Swarm. It shows what it changes, uses official Docker packages, and keeps generated secrets out of Git.

## Choose your journey

| Journey | Supported system | Result |
|---|---|---|
| Windows local | Windows 11, WSL2, Linux containers | Portainer at `http://portainer.localhost` |
| Linux local | Ubuntu 22.04 or 24.04 | Portainer at `http://portainer.localhost` |
| Linux server | Ubuntu Server 22.04 or 24.04 | Portainer on your domain with Let's Encrypt HTTPS |

### Complete guides

- [Windows 11 local: from zero to Portainer](docs/en/windows-local.md)
- [Ubuntu local: Docker Engine and a one-node Swarm](docs/en/linux-local.md)
- [Ubuntu Server: DNS, firewall, Traefik and HTTPS](docs/en/linux-server.md)
- [Architecture and security boundaries](docs/en/architecture.md)
- [Troubleshooting guide](docs/en/troubleshooting.md)
- [Release acceptance checklist](docs/testing.md)

This project targets learning, development, home labs, and small self-hosted environments. The v1 architecture is single-manager and is not advertised as a production high-availability cluster.

## What gets installed

- Docker Engine on Ubuntu, or Docker Desktop on Windows.
- A single-node Docker Swarm.
- Traefik v3 as reverse proxy.
- Portainer CE LTS and its matching Agent.
- An overlay network shared by Traefik and routed services.

Every installer prints its actions and asks before modifying the machine.

## Quick start

Clone the repository first:

```bash
git clone https://github.com/agosalvez/easy-devops.git
cd easy-devops
```

### Windows local

Open PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\installers\windows-local.ps1
```

If Docker Desktop has just been installed, start it, complete its first-run setup, and run the installer again.

### Ubuntu local

```bash
chmod +x installers/linux-local.sh scripts/linux/manage.sh
./installers/linux-local.sh
```

### Ubuntu Server

Before starting, create a DNS A record pointing a domain such as `portainer.example.com` to the server's public IPv4 address. Allow inbound TCP ports 80 and 443.

```bash
chmod +x installers/linux-server.sh scripts/linux/manage.sh
./installers/linux-server.sh
```

The installer refuses certificate deployment when DNS does not match the server public IP.

## Architecture

```text
Browser
   |
   | HTTP locally / HTTPS on server
   v
Traefik
   |
   | private overlay network
   v
Portainer Server <----TLS----> Portainer Agent
   |                               |
   +---------- Docker Swarm -------+
```

Server mode publishes only ports 80 and 443. Portainer port 9000 and the insecure Traefik dashboard are not published.

## Daily operations

Linux:

```bash
./scripts/linux/manage.sh status
./scripts/linux/manage.sh start
./scripts/linux/manage.sh stop
./scripts/linux/manage.sh backup
./scripts/linux/manage.sh update
./scripts/linux/manage.sh uninstall
```

Windows:

```powershell
.\scripts\windows\manage.ps1 status
.\scripts\windows\manage.ps1 start
.\scripts\windows\manage.ps1 stop
.\scripts\windows\manage.ps1 update
.\scripts\windows\manage.ps1 uninstall
```

Uninstall keeps Portainer data by default. Linux backups are written to the ignored `backups/` directory.

## Troubleshooting

### Docker is installed but unavailable

On Ubuntu, log out and back in after the installer adds your user to the `docker` group. The installer can use `sudo docker` during the initial run.

On Windows, ensure Docker Desktop is running and configured for Linux containers.

### Portainer does not open

Run the status command and confirm each service has its expected replica. Initial image downloads and Let's Encrypt issuance can take a minute.

### HTTPS certificate is not issued

Confirm the domain resolves publicly to the server, ports 80/443 are reachable, and no other service occupies those ports. Inspect Traefik with:

```bash
docker service logs easy-devops-traefik_traefik
```

## Security notes

Docker socket access is highly privileged. This project mounts it read-only into Traefik and necessarily exposes it to the Portainer Agent. Only trusted administrators should access the host.

Never commit `.env`, ACME state, certificates, backups, or logs. Read [SECURITY.md](SECURITY.md) before exposing the server to the internet.

## Project status

The project is being rebuilt for v1.0 on `feature/easy-installers`. Windows 11 and clean Ubuntu 22.04/24.04 acceptance tests are required before the release is merged into `main`.

## Author

Created and maintained by [Adrián Gosálvez](https://github.com/agosalvez).

## License

MIT
