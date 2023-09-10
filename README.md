# [Docker Swarm + Traefik for developers](https://github.com/agosalvez/devops-for-developers)

[![GitHub last commit](https://img.shields.io/github/last-commit/agosalvez/devops-for-developers.svg)](https://github.com/agosalvez/devops-for-developers/commits/main)
![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/t/agosalvez/devops-for-developers)
![GitHub contributors](https://img.shields.io/github/contributors/agosalvez/devops-for-developers)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/agosalvez/devops-for-developers)

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
git clone https://github.com/agosalvez/devops-for-developers.git
```

```
cd devops-for-developers/swarm/https
```

### Edit for Let's Encrypt (https mode)

- traefik.yml:14 => Set your email

### Deploy cluster

Next script will create a pair of docker networks and deploy the traefik and portainer stacks:

```
./initCluster.sh
```

#### Local => /etc/hosts

Modify if you want portainer.yml:31 with your domain

```
# Add the following line (or your domain) to the end of the /etc/hosts file:
127.0.0.1   portainer.mylab.com
```

#### Cloud server

- Redirect you desired domain to your server public IP and configure right labels in stack yaml

## Usage

Go to https://portainer.mylab.com to try it!

## Bonus extra

After that, you can start and stop this cluster with these scripts:

```
./startCluster.sh
```

or

```
./stopCluster.sh
```

## Acknowledgements

- Author: [Adrián Gosálvez](https://github.com/agosalvez)
- Collaborator: [Javier Pérez](https://github.com/jaweewo)

## Documentation

**[Docker Documentation](https://docs.docker.com/get-started/overview/)**

**[Portainer Documentation](https://docs.portainer.io/)**

## Other features

[Kubernetes - Microk8s](https://github.com/agosalvez/Devops/tree/main/Kubernetes/Microk8s)

### If you want to know more, let me know!
