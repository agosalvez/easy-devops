# Arquitectura

```text
Cliente
  |
  | HTTP local o HTTPS en servidor
  v
Traefik (manager)
  |
  | red overlay easy-devops-proxy
  v
Portainer Server (manager)
  |
  | protocolo cifrado del Agent
  v
Portainer Agent global -> Docker y metadatos de volúmenes
```

Traefik descubre las rutas desde `deploy.labels` de los servicios Swarm.
Traefik y Portainer Server se ejecutan en managers; el Agent se ejecuta en cada
nodo Linux.

La red proxy conecta los dos stacks. Otra red privada conecta Portainer con sus
Agents. Los volúmenes conservan datos de Portainer y certificados ACME. El modo
servidor solo publica 80 y 443; no publica 9000 ni el dashboard inseguro.

La versión 1 utiliza un manager. Añadir workers es posible, pero múltiples
managers, quórum, almacenamiento compartido y recuperación completa requieren
un diseño específico de alta disponibilidad.

