# Acceptance test checklist

Run these tests after the repository and CI are online. Record the operating
system version, Docker version, command output, result, and any correction.

## Windows 11 local

- [ ] Start from a machine without Docker Desktop.
- [ ] Run the documented PowerShell installer as Administrator.
- [ ] Confirm first run installs Docker Desktop and stops with resume guidance.
- [ ] Start Docker Desktop and rerun the installer.
- [ ] Confirm one Swarm manager and healthy Traefik, Portainer, and Agent.
- [ ] Open `http://portainer.localhost` and create the initial administrator.
- [ ] Exercise status, stop, start, update, and uninstall.
- [ ] Confirm uninstall preserves Portainer data.

## Ubuntu 22.04 and 24.04 local

- [ ] Start from a clean supported Ubuntu installation.
- [ ] Run the local installer with a sudo-enabled non-root user.
- [ ] Confirm Docker comes from Docker's official apt repository.
- [ ] Confirm Swarm, overlay network, services, and local HTTP route.
- [ ] Exercise status, backup, update, stop, start, and uninstall.
- [ ] Restore or inspect the backup archive.

## Ubuntu Server 22.04 and 24.04

- [ ] Prepare a disposable server, public IPv4, DNS A record, and open 80/443.
- [ ] Confirm the installer rejects mismatched DNS.
- [ ] Run the server installer after DNS matches.
- [ ] Confirm HTTP redirects to HTTPS.
- [ ] Confirm a trusted Let's Encrypt certificate.
- [ ] Confirm 9000, 9443, and 8080 are not publicly listening.
- [ ] Exercise backup and update.
- [ ] Reboot the host and confirm services recover.

## Release gate

Do not publish `v1.0.0` or promote the repository until CI is green and all
applicable checks above pass. Document accepted limitations in the changelog.

