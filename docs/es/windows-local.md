# Instalación local en Windows 11

Esta ruta crea un Docker Swarm de un nodo y publica Portainer en
`http://portainer.localhost`.

## Requisitos

- Windows 11 con virtualización activada.
- Permisos de administrador.
- Conexión a Internet, 8 GB de RAM y 10 GB libres.
- Contenedores Linux.

## Pasos

```powershell
git clone https://github.com/agosalvez/easy-devops.git
Set-Location easy-devops
Set-ExecutionPolicy -Scope Process Bypass
.\installers\windows-local.ps1
```

Revisa los cambios y confirma. Si se instala Docker Desktop, ábrelo, completa
su configuración inicial, espera a que arranque el motor y repite el último
comando. Después de aproximadamente un minuto abre
`http://portainer.localhost` y crea inmediatamente el administrador inicial.

## Validación y gestión

```powershell
docker node ls
.\scripts\windows\manage.ps1 status
.\scripts\windows\manage.ps1 start
.\scripts\windows\manage.ps1 stop
.\scripts\windows\manage.ps1 update
.\scripts\windows\manage.ps1 uninstall
```

Si falla, comprueba que Docker Desktop usa contenedores Linux y que ningún
servicio como IIS ocupa el puerto 80. La desinstalación conserva los datos.

