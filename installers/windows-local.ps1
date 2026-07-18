#Requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
Import-Module "$Root/lib/powershell/Common.psm1" -Force

$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Run PowerShell as Administrator.'
}
Write-StepInfo 'Easy DevOps will install Docker Desktop, enable its WSL2 backend, initialize Swarm, and deploy Portainer.'
if ((Read-Host 'Continue? [y/N]') -notmatch '^[Yy]$') { return }

if (-not (Test-CommandAvailable 'winget')) { throw 'winget is required. Install App Installer from Microsoft Store.' }
if (-not (Test-CommandAvailable 'docker')) {
    winget install --id Docker.DockerDesktop --exact --accept-package-agreements --accept-source-agreements
    Write-StepInfo 'Start Docker Desktop, complete its first-run setup, then run this script again.'
    return
}
docker info | Out-Null
if ((docker info --format '{{.Swarm.LocalNodeState}}') -ne 'active') { docker swarm init | Out-Null }
docker network inspect easy-devops-proxy 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { docker network create --driver overlay --attachable easy-devops-proxy | Out-Null }

$env:TRAEFIK_IMAGE = 'traefik:v3.7'
$env:PORTAINER_IMAGE = 'portainer/portainer-ce:lts'
$env:PORTAINER_AGENT_IMAGE = 'portainer/agent:lts'
$env:EASY_DEVOPS_DOMAIN = 'portainer.localhost'
docker stack deploy -c "$Root/stacks/local/traefik.yml" easy-devops-traefik
docker stack deploy -c "$Root/stacks/local/portainer.yml" easy-devops-portainer
Write-StepSuccess 'Deployment submitted. Open http://portainer.localhost in about one minute.'

