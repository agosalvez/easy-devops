@echo off

REM Desplegar stacks de Docker
docker stack deploy -c ../traefik.yml traefik
docker stack deploy -c ../portainer.yml portainer

pause
