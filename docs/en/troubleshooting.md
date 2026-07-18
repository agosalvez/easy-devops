# Troubleshooting

Start with:

```bash
docker info
docker node ls
docker service ls
docker stack services easy-devops-traefik
docker stack services easy-devops-portainer
```

## A service has 0/1 replicas

Inspect tasks and logs:

```bash
docker service ps --no-trunc easy-devops-portainer_portainer
docker service logs easy-devops-portainer_portainer
docker service ps --no-trunc easy-devops-traefik_traefik
docker service logs easy-devops-traefik_traefik
```

Common causes are unavailable ports, failed image downloads, manager placement,
or invalid environment values.

## Port 80 or 443 is already allocated

Linux:

```bash
sudo ss -ltnp | grep -E ':(80|443)\b'
```

Windows:

```powershell
Get-NetTCPConnection -State Listen -LocalPort 80,443
```

Stop or reconfigure the conflicting service before redeploying.

## DNS or certificate failure

```bash
getent ahostsv4 portainer.example.com
curl -4 https://api.ipify.org
docker service logs easy-devops-traefik_traefik
```

DNS must resolve publicly to the server. Port 80 must remain reachable for the
ACME HTTP challenge even though normal traffic redirects to HTTPS.

## Resetting only the running services

```bash
./scripts/linux/manage.sh stop
./scripts/linux/manage.sh start
```

This preserves Portainer data. Do not delete the Portainer volume unless a
verified backup exists and permanent data loss is intended.

## Reporting a problem

Include operating system version, Docker version, the exact command, sanitized
output, service task state, and relevant logs. Remove domains, public IPs, email
addresses, tokens, keys, certificates, and credentials.

