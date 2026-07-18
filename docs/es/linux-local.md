# Instalación local en Ubuntu

Compatible con Ubuntu 22.04 y 24.04. Requiere un usuario normal con `sudo`,
Internet y el puerto TCP 80 libre.

## Instalación

```bash
git clone https://github.com/agosalvez/easy-devops.git
cd easy-devops
chmod +x installers/linux-local.sh scripts/linux/manage.sh
./installers/linux-local.sh
```

El asistente instala Docker desde el repositorio apt oficial, inicializa Swarm,
crea la red overlay y despliega Traefik y Portainer. Si acaba de añadir tu
usuario al grupo `docker`, cierra sesión y vuelve a entrar.

## Validación y gestión

```bash
docker node ls
./scripts/linux/manage.sh status
curl -I -H 'Host: portainer.localhost' http://127.0.0.1
./scripts/linux/manage.sh backup
./scripts/linux/manage.sh update
```

El resultado se abre en `http://portainer.localhost`. Los backups se guardan
en `backups/` y no se versionan.

