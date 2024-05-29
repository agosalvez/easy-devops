@echo off

REM Crear redes de Docker
docker network create -d overlay traefik
docker network create -d overlay portainer

REM Desplegar stacks de Docker
docker stack deploy -c ../traefik.yml traefik
docker stack deploy -c ../portainer.yml portainer

pause