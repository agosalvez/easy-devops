# Ubuntu Server installation

This journey deploys Portainer behind Traefik with a public domain and automatic
Let's Encrypt HTTPS.

## Requirements

- Ubuntu Server 22.04 or 24.04.
- A normal user with `sudo` access.
- A public IPv4 address.
- A DNS A record pointing the chosen domain to that address.
- Inbound TCP ports 80 and 443 available.
- For multi-node expansion: Swarm ports 2377/TCP, 7946/TCP+UDP and 4789/UDP
  restricted to trusted node addresses.

## Prepare DNS and firewall

Create an A record such as:

```text
portainer.example.com -> 203.0.113.10
```

Wait until public DNS returns the server address:

```bash
getent ahostsv4 portainer.example.com
curl -4 https://api.ipify.org
```

If UFW is active:

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw status
```

Keep the SSH rule before enabling or changing the firewall.

## Installation

```bash
git clone https://github.com/agosalvez/easy-devops.git
cd easy-devops
chmod +x installers/linux-server.sh scripts/linux/manage.sh
./installers/linux-server.sh
```

Enter the complete Portainer domain and a valid Let's Encrypt contact email.
The installer stops if DNS does not match the public server address.

## Validation

```bash
./scripts/linux/manage.sh status
docker service logs easy-devops-traefik_traefik
curl -I https://portainer.example.com
```

Expected: HTTPS succeeds with a trusted certificate and redirects HTTP to HTTPS.
Create the first Portainer administrator account immediately.

## Security checklist

- Do not publish ports 9000, 9443, or 8080.
- Restrict SSH and Swarm node ports.
- Keep `.env`, backups, logs, and certificates outside Git.
- Back up Portainer before updates.
- Patch Ubuntu and Docker regularly.
- Do not use this single-manager design as high availability.

## Updates and recovery

```bash
./scripts/linux/manage.sh backup
./scripts/linux/manage.sh update
./scripts/linux/manage.sh status
```

If an update fails, inspect service logs and redeploy the previous explicit image
values from `.env`.

