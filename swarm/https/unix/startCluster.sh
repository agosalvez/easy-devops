#!/bin/bash

docker stack deploy -c ../traefik.yml traefik
docker stack deploy -c ../portainer.yml portainer
