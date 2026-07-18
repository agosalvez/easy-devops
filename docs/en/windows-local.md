# Windows 11 local installation

This journey creates a single-node Docker Swarm and exposes Portainer at
`http://portainer.localhost`.

## Requirements

- Windows 11 with hardware virtualization enabled.
- Administrator access.
- Internet access.
- At least 8 GB RAM and 10 GB free disk space.
- Linux containers. Windows containers are not supported.

## Installation

1. Clone the repository.

   ```powershell
   git clone https://github.com/agosalvez/easy-devops.git
   Set-Location easy-devops
   ```

2. Open PowerShell as Administrator.

3. Allow scripts only for the current process and start the installer.

   ```powershell
   Set-ExecutionPolicy -Scope Process Bypass
   .\installers\windows-local.ps1
   ```

4. Review the displayed changes and confirm.

5. If Docker Desktop is installed during this run, open it, accept its
   first-run terms, wait until Docker reports that the engine is running, and
   execute step 3 again.

6. Wait about one minute and open `http://portainer.localhost`.

7. Create the first Portainer administrator account immediately. Portainer
   intentionally expires the initial setup page when left unattended.

## Validation

```powershell
docker node ls
docker stack services easy-devops-traefik
docker stack services easy-devops-portainer
.\scripts\windows\manage.ps1 status
```

Expected: one manager node and one running replica for Traefik and Portainer.
The Agent service runs globally.

## Daily operations

```powershell
.\scripts\windows\manage.ps1 start
.\scripts\windows\manage.ps1 stop
.\scripts\windows\manage.ps1 update
.\scripts\windows\manage.ps1 uninstall
```

Uninstall removes stacks but keeps Portainer data.

## Common problems

- **Docker command missing:** restart PowerShell after Docker Desktop installation.
- **Docker daemon unavailable:** start Docker Desktop and select Linux containers.
- **Port 80 busy:** stop IIS, another proxy, or the application using the port.
- **URL not resolving:** test `http://localhost` with header
  `Host: portainer.localhost`, and check local DNS/security software.

