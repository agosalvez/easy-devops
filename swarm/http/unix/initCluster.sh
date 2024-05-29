#!/bin/bash

docker network create -d overlay traefik
docker network create -d overlay portainer

docker stack deploy -c ../traefik.yml traefik
docker stack deploy -c ../portainer.yml portainer
