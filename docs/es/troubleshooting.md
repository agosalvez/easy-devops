# Solución de problemas

Empieza siempre por:

```bash
docker info
docker node ls
docker service ls
docker stack services easy-devops-traefik
docker stack services easy-devops-portainer
```

## Réplicas en 0/1

```bash
docker service ps --no-trunc easy-devops-portainer_portainer
docker service logs easy-devops-portainer_portainer
docker service ps --no-trunc easy-devops-traefik_traefik
docker service logs easy-devops-traefik_traefik
```

Revisa puertos ocupados, descarga de imágenes, restricciones del manager y
variables de entorno.

## Puertos ocupados

Linux:

```bash
sudo ss -ltnp | grep -E ':(80|443)\b'
```

Windows:

```powershell
Get-NetTCPConnection -State Listen -LocalPort 80,443
```

## DNS o HTTPS

```bash
getent ahostsv4 portainer.example.com
curl -4 https://api.ipify.org
docker service logs easy-devops-traefik_traefik
```

El DNS debe devolver la IP pública. El puerto 80 debe ser accesible para el
reto ACME aunque el tráfico normal redirija a HTTPS.

Para reiniciar servicios conservando datos:

```bash
./scripts/linux/manage.sh stop
./scripts/linux/manage.sh start
```

Al reportar un error incluye sistema, versión de Docker, comando, estado de
tareas y logs sanitizados. Elimina dominios, IP públicas, correos, tokens,
claves, certificados y credenciales.

