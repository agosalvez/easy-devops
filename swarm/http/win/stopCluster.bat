@echo off

REM Eliminar stacks de Docker
docker stack rm portainer
docker stack rm traefik

pause
