# Instalación en Ubuntu Server

Despliega Portainer detrás de Traefik con dominio público y HTTPS automático.

## Requisitos

- Ubuntu Server 22.04 o 24.04.
- Usuario normal con `sudo`.
- IPv4 pública y registro DNS A apuntando a ella.
- Puertos TCP 80 y 443 abiertos.

Comprueba DNS antes de empezar:

```bash
getent ahostsv4 portainer.example.com
curl -4 https://api.ipify.org
```

Si utilizas UFW, conserva SSH y permite web:

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw status
```

## Instalación

```bash
git clone https://github.com/agosalvez/easy-devops.git
cd easy-devops
chmod +x installers/linux-server.sh scripts/linux/manage.sh
./installers/linux-server.sh
```

Introduce el dominio completo y el correo de Let's Encrypt. El instalador se
detiene si el DNS no coincide con la IP pública.

## Validación

```bash
./scripts/linux/manage.sh status
docker service logs easy-devops-traefik_traefik
curl -I https://portainer.example.com
```

El certificado debe ser válido y HTTP debe redirigir a HTTPS. No publiques
9000, 9443 ni 8080. Restringe SSH y los puertos internos de Swarm, crea backups
antes de actualizar y no presentes este diseño de un manager como alta
disponibilidad.

