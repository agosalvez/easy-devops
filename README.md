# DevOps Repo

## Swarm 1 nodo

```
docker swarm init
````

## Traefik

Creamos la red tipo overlay para traefik:
```
docker network create -d overlay traefik
```
<br>

Desplegamos el stack de traefik:
```
docker stack deploy -c traefik.yml traefik
```
<br>


## Portainer
Desplegamos el stack de portainer:
```
docker stack deploy -c portainer.yml portainer
```
Puede tardar un poco hasta que portainer levante al agent completamente.


