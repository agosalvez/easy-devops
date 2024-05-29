# [Docker Swarm + Traefik for developers](https://github.com/agosalvez/easy-devops)

[![GitHub last commit](https://img.shields.io/github/last-commit/agosalvez/easy-devops.svg)](https://github.com/agosalvez/easy-devops/commits/main)
![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/t/agosalvez/easy-devops)
![GitHub contributors](https://img.shields.io/github/contributors/agosalvez/easy-devops)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/agosalvez/easy-devops)

With this cluster you can deploy in your localhost or your cloud server a Docker Swarm to develop or you can test a Docker-based ecosystem of applications for you.
It is not recommended to use for production environments.

## Requirements

- Knowledges: docker, docker-compose, swarm, DNS
- To have installed docker previously

## Installation

We have to join in a cluster mode with next command in your machine:

```
docker swarm init
```

OPTIONAL: If you have more than 1 node, click [here](https://docs.docker.com/engine/swarm/swarm-tutorial/add-nodes/)

### Clone repository and choose protocol: http or https, in this example we will use https

```
git clone https://github.com/agosalvez/easy-devops.git
```

Local:
```
cd easy-devops/swarm/http
```
Cloud server:
```
cd easy-devops/swarm/https
```
### Edit for Let's Encrypt (only https mode)

- traefik.yml:14 => Set your own email for letsencrypt

### Deploy cluster

Next script will create a pair of docker networks and deploy the traefik and portainer stacks:

Windows
```
./win/initCluster.bat
```
Unix
```
./unix/initCluster.sh
```

### Local

#### /etc/hosts

Modify portainer.yml:31 with your desired domain (your own domain if you are in a server)

```
# Add the following line (or your domain) to the end of the /etc/hosts file:
127.0.0.1   portainer.mylab.com
```
The domain have to be exactly in hosts file and portainer.yml:31 

### Cloud server

- Redirect you desired domain to your server public IP and configure right labels in portainer.yml:31

## Usage

### Local
Go to http://portainer.mylab.com 

### Cloud server
Go to https://portainer.mylab.com (or your domain setted in portainer.yml) to try it!

## Bonus extra

After that, you can start and stop this cluster with these scripts:

### Start cluster

Windows
```
./win/startCluster.bat
```
Unix
```
./unix/startCluster.sh
```
### Stop cluster

Windows
```
./win/stopCluster.bat
```
Unix
```
./unix/stopCluster.sh
```

## Authors

- Main author: [Adrián Gosálvez](https://github.com/agosalvez)
- Collaborator: [Javier Pérez](https://github.com/jaweewo)

## Documentation

**[Docker Documentation](https://docs.docker.com/get-started/overview/)**

**[Portainer Documentation](https://docs.portainer.io/)**

## Other features

[Kubernetes - Microk8s](https://github.com/agosalvez/Devops/tree/main/Kubernetes/Microk8s)
