#Requires -Version 5.1
[CmdletBinding()]
param([ValidateSet('status','start','stop','update','uninstall')][string]$Action = 'status')
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$env:TRAEFIK_IMAGE = 'traefik:v3.7'
$env:PORTAINER_IMAGE = 'portainer/portainer-ce:lts'
$env:PORTAINER_AGENT_IMAGE = 'portainer/agent:lts'
$env:EASY_DEVOPS_DOMAIN = 'portainer.localhost'
switch ($Action) {
    status { docker node ls; docker stack services easy-devops-traefik; docker stack services easy-devops-portainer }
    start {
        docker network inspect easy-devops-proxy 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) { docker network create --driver overlay --attachable easy-devops-proxy | Out-Null }
        docker stack deploy -c "$Root/stacks/local/traefik.yml" easy-devops-traefik
        docker stack deploy -c "$Root/stacks/local/portainer.yml" easy-devops-portainer
    }
    stop { docker stack rm easy-devops-portainer; docker stack rm easy-devops-traefik }
    update {
        docker pull $env:TRAEFIK_IMAGE
        docker pull $env:PORTAINER_IMAGE
        docker pull $env:PORTAINER_AGENT_IMAGE
        & $PSCommandPath start
    }
    uninstall {
        if ((Read-Host 'Remove Easy DevOps stacks but keep data? [y/N]') -match '^[Yy]$') { & $PSCommandPath stop }
    }
}
