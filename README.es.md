# Easy DevOps

[![Quality](https://github.com/agosalvez/easy-devops/actions/workflows/quality.yml/badge.svg)](https://github.com/agosalvez/easy-devops/actions/workflows/quality.yml)
[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-blue.svg)](LICENSE)
[![Docker Swarm](https://img.shields.io/badge/Docker-Swarm-2496ED?logo=docker&logoColor=white)](https://docs.docker.com/engine/swarm/)

> Monta un Docker Swarm local o en tu propio servidor con Traefik y Portainer mediante un instalador guiado y transparente.

[English](README.md) · [Seguridad](SECURITY.md) · [Diseño](docs/superpowers/specs/2026-07-18-easy-devops-v1-design.md)

Easy DevOps lleva una máquina vacía hasta un Docker Swarm administrable. Explica los cambios, instala Docker desde fuentes oficiales y mantiene secretos y datos generados fuera de Git.

## Elige tu recorrido

| Recorrido | Sistema compatible | Resultado |
|---|---|---|
| Windows local | Windows 11, WSL2 y contenedores Linux | `http://portainer.localhost` |
| Linux local | Ubuntu 22.04 o 24.04 | `http://portainer.localhost` |
| Servidor Linux | Ubuntu Server 22.04 o 24.04 | Tu dominio con HTTPS de Let's Encrypt |

### Guías completas

- [Windows 11 local: desde cero hasta Portainer](docs/es/windows-local.md)
- [Ubuntu local: Docker Engine y Swarm de un nodo](docs/es/linux-local.md)
- [Ubuntu Server: DNS, firewall, Traefik y HTTPS](docs/es/linux-server.md)
- [Arquitectura y límites de seguridad](docs/es/architecture.md)
- [Guía de solución de problemas](docs/es/troubleshooting.md)
- [Checklist de pruebas antes de publicar](docs/testing.md)

Está pensado para aprendizaje, desarrollo, home labs y pequeños entornos propios. La arquitectura v1 utiliza un solo manager y no se presenta como un clúster productivo de alta disponibilidad.

## Instalación rápida

```bash
git clone https://github.com/agosalvez/easy-devops.git
cd easy-devops
```

### Windows local

Abre PowerShell como administrador:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\installers\windows-local.ps1
```

Si acaba de instalar Docker Desktop, ábrelo, completa la configuración inicial y vuelve a ejecutar el instalador.

### Ubuntu local

```bash
chmod +x installers/linux-local.sh scripts/linux/manage.sh
./installers/linux-local.sh
```

### Ubuntu Server

Crea primero un registro DNS A que apunte tu dominio a la IPv4 pública del servidor y permite los puertos TCP 80 y 443.

```bash
chmod +x installers/linux-server.sh scripts/linux/manage.sh
./installers/linux-server.sh
```

El instalador solicita dominio y correo, comprueba el DNS y solo después despliega HTTPS.

## Qué se instala

- Docker Engine en Ubuntu o Docker Desktop en Windows.
- Docker Swarm de un nodo.
- Traefik v3 como proxy inverso.
- Portainer CE LTS y un Agent compatible.
- Una red overlay privada.

El modo servidor solo publica 80 y 443. No expone el puerto 9000 de Portainer ni el dashboard inseguro de Traefik.

## Operaciones habituales

Linux:

```bash
./scripts/linux/manage.sh status
./scripts/linux/manage.sh start
./scripts/linux/manage.sh stop
./scripts/linux/manage.sh backup
./scripts/linux/manage.sh update
./scripts/linux/manage.sh uninstall
```

Windows:

```powershell
.\scripts\windows\manage.ps1 status
.\scripts\windows\manage.ps1 start
.\scripts\windows\manage.ps1 stop
.\scripts\windows\manage.ps1 update
.\scripts\windows\manage.ps1 uninstall
```

La desinstalación conserva los datos. En Linux, los backups se guardan en `backups/`, ignorado por Git.

## Solución de problemas

- Si Docker no responde en Ubuntu, cierra la sesión y vuelve a entrar para aplicar el grupo `docker`.
- Si no abre Portainer, ejecuta `./scripts/linux/manage.sh status` y espera a que terminen las descargas.
- Si falla HTTPS, revisa DNS, puertos 80/443 y los logs con `docker service logs easy-devops-traefik_traefik`.
- En Windows, confirma que Docker Desktop está abierto y usa contenedores Linux.

## Seguridad

El socket de Docker concede mucho control sobre el host. Solo administradores de confianza deben acceder. No publiques `.env`, certificados, estado ACME, logs o backups. Consulta [SECURITY.md](SECURITY.md).

## Estado

La candidata a v1 ya está disponible en `main`. Antes de publicar la release
`v1.0.0` debe superar las pruebas de aceptación en Windows 11 y en instalaciones
limpias de Ubuntu 22.04/24.04.

## Contribuir

Las contribuciones son bienvenidas. Haz un fork, crea una rama centrada en un
único cambio, valida el resultado y abre una pull request:

```bash
git clone https://github.com/TU_USUARIO_GITHUB/easy-devops.git
cd easy-devops
git remote add upstream https://github.com/agosalvez/easy-devops.git
git switch -c feature/descripcion-corta

# Realiza y valida los cambios.
git diff --check

git add <archivos-modificados>
git commit -m "feat(scope): describe the change"
git push -u origin feature/descripcion-corta
```

Después abre una pull request desde tu fork hacia
`agosalvez/easy-devops:main`. Mantén cada PR enfocada, explica cómo la has
probado, escribe los commits en inglés y nunca incluyas credenciales o datos
generados. Consulta la [guía de contribución](CONTRIBUTING.md) y la
[política de seguridad](SECURITY.md).

## Autor

Creado y mantenido por [Adrián Gosálvez](https://adrian.gosalvez.es).

- [Web profesional y CV](https://adrian.gosalvez.es)
- [LinkedIn](https://www.linkedin.com/in/adriangosalvez/)
- [GitHub](https://github.com/agosalvez)

## Licencia

MIT
