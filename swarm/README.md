# Creando un clúster con Docker Swarm
### Creamos el clúster
```
docker swam init
```
En caso de tener más de 1 máquina, añadimos los workers con la instrucción:
```
docker swarm join --token TOKEN-DEL-NODO-WORKER
```
### Creamos las redes tipo overlay para traefik y portainer
```
docker network create -d overlay traefik
```
```
docker network create -d overlay portainer
```
### Creamos los stacks de traefik primero y seguidamente el de portainer
Añadimos Traefik:
```
docker stack deploy -c traefik.yml traefik
```
```
version: '3'

services:
  traefik:
    image: traefik:v2.2
    command:
      - "--providers.docker.endpoint=unix:///var/run/docker.sock"
      - "--providers.docker.swarmMode=true"
      - "--providers.docker.exposedbydefault=false"
      - "--providers.docker.network=traefik"
      - "--entrypoints.web.address=:80"
      - "--api.dashboard=true"
      - "--api.insecure=true"
    ports:
      - "80:80"
      - "8080:8080"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - traefik
    deploy:
      placement:
        constraints:
          - node.role == manager

networks:
  traefik:
    external: true
```
Añadimos Portainer:
```
docker stack deploy -c portainer.yml portainer
```
```
version: '3.2'

services:
  agent:
    image: portainer/agent
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
    networks:
      - portainer
    deploy:
      mode: global
      placement:
        constraints:
          - node.role == manager

  app:
    image: portainer/portainer-ce
    command: -H tcp://tasks.agent:9001 --tlsskipverify
    volumes:
      - portainer:/data
    ports:
      - '9000:9000'
    networks:
      - portainer
      - traefik
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - 'traefik.enable=true'
        - 'traefik.http.routers.portainer.rule=Host(`portainer.milab.es`)'
        - 'traefik.http.routers.portainer.entrypoints=web'
        - 'traefik.http.services.portainer.loadbalancer.server.port=9000'

networks:
  portainer:
    driver: overlay
    attachable: true
  traefik:
    external: true

volumes:
  portainer:

```
### Damos de alta las direcciones en el fichero: /etc/hosts (en caso de local) o en el dns en caso de ser un servidor
#### Local
```
Añadimos al final en el fichero /etc/hosts:
127.0.0.1   portainer.milab.es
``` 
