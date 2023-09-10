# Creando un clúster con Microk8s
### Instalamos snap en nuestra máquina (Omitir si usamos Ubuntu 18 o superior)
```
sudo apt install snapd
```
```
sudo snap install core
```
### Instalamos microk8s utilizando snap
```
sudo snap install microk8s --classic --channel=1.24
```
### Nos unimos al grupo microk8s
```
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
```
### Comprobamos el estado 
```
microk8s status
```
### Creación de alias
```
echo "alias kubectl='microk8s kubectl'" >> ~/.bash_aliases
```
Luego dependiendo de nuestras necesidades, deberemos instalar un addon:
Referencia: https://microk8s.io/docs/addons#heading--list

### Adicion de nodos al clúster
```
microk8s add-node
```
Esto nos devolverá una información similar a esto:
```
From the node you wish to join to this cluster, run the following:
microk8s join 192.168.1.230:25000/92b2db237428470dc4fcfc4ebbd9dc81/2c0cb3284b05

Use the '--worker' flag to join a node as a worker not running the control plane, eg:
microk8s join 192.168.1.230:25000/92b2db237428470dc4fcfc4ebbd9dc81/2c0cb3284b05 --worker

If the node you are adding is not reachable through the default interface you can use one of the following:
microk8s join 192.168.1.230:25000/92b2db237428470dc4fcfc4ebbd9dc81/2c0cb3284b05
microk8s join 10.23.209.1:25000/92b2db237428470dc4fcfc4ebbd9dc81/2c0cb3284b05
microk8s join 172.17.0.1:25000/92b2db237428470dc4fcfc4ebbd9dc81/2c0cb3284b05
```
Si solo hacemos un microk8s join, este nodo se unirá con los 3 roles (etcd, controlpanel y worker)
Si solo necesitamos un nodo worker podemos realizar lo siguiente:
```
microk8s join 192.168.1.230:25000/92b2db237428470dc4fcfc4ebbd9dc81/2c0cb3284b05 --worker
```

### Estructura recomendada
Se recomienda generar una estructura con IPs balanceadas, haciendo uso de un software como "MetalLB" , asignar una de esas IPs a nuestro traefik y levantar servicios.
Ejemplos en las carpetas correspondientes de este mismo repo.