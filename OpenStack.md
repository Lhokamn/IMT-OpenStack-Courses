# OpenStack 


## Openstack CLI

Jouons avec OpenStack CLI

### Pré-requis : créer un fichier pour les credential admin

```sh
cat admin.credential 
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=admin
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=secret
export OS_AUTH_URL=http://172.16.37.140/identity
export OS_IDENTITY_API_VERSION=3


source admin.credential

openstack token issue
```

### créer un projet et mettre un utilisateur dedans

```sh
# Create a project
openstack project create --domain default --description "Imt Test project" imt

# Create a user
openstack user create --domain default --password-prompt imt

# Create role imt
openstack role create imt

# Add user and group to project
openstack role add --project imt --user imt member
```

maintenant nous allons créer le fichier imt.crendential pour que l'utilisateur puisse gérer son projet

```sh
$ cat imt.credential 
export OS_PROJECT_DOMAIN_ID=default
export OS_USER_DOMAIN_ID=default
export OS_PROJECT_NAME=imt
export OS_TENANT_NAME=admin
export OS_USERNAME=imt
export OS_PASSWORD=imt
export OS_AUTH_URL=http://172.16.37.140/identity
export OS_IDENTITY_API_VERSION=3

$ source imt.credential 
$ openstack token issue
```

### Pass public ssh key

```sh
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_openstack -N ""

openstack keypair create --public-key ~/.ssh/id_rsa_openstack.pub imt-key
```

### Create security group

```sh
openstack security group create sec-http --description "Autorise HTTP/HTTPS"
openstack security group create sec-icmp --description "Autorise le Ping"
openstack security group create sec-ssh  --description "Autorise le SSH"

openstack security group rule create --protocol tcp --dst-port 80:80 sec-http
openstack security group rule create --protocol tcp --dst-port 443:443 sec-http
openstack security group rule create --protocol icmp sec-icmp
openstack security group rule create --protocol tcp --dst-port 22:22 sec-ssh
```

### Création du réseau privée

```sh
# Créer le réseau
openstack network create imt-lan

# Créer le sous-réseau (ex: 192.168.10.0/24)
openstack subnet create --network imt-lan --subnet-range 192.168.10.0/24 imt-subnet

# créer un routeur pour relier le réseau au réseau public
openstack router create imt-router

# define gateway
openstack router set --external-gateway public imt-router

# link all network
openstack router add subnet imt-router imt-subnet
```

### Créer une image avec CIRROS

```sh
# on récupère l'id de l'image
IMAGE_ID=$(openstack image list -f value -c Name | grep cirros | head -1)

echo $IMAGE_ID
cirros-0.6.3-x86_64-disk

openstack server create --flavor m1.tiny   --image $IMAGE_ID   --network imt-lan   --key-name imt-key   --security-group sec-http   --security-group sec-icmp   --security-group sec-ssh   imt-instance-01
```

### Se conencter à la vm 

1. Attribuer une ip flottante

```sh
# 1. Créer une IP flottante sur le réseau public
FLOATING_IP=$(openstack floating ip create public -f value -c floating_ip_address)

# 2. Associer cette IP à votre instance
openstack server add floating ip imt-instance-01 $FLOATING_IP

# 3. Afficher l'IP pour la connexion
echo "Votre IP publique est : $FLOATING_IP"
```

2. Se connecter avec ssh

```sh
ssh -i ~/.ssh/id_rsa_openstack cirros@$FLOATING_IP
```

Si il y a des problèmes, il faut regarder l'interface ``br-ex``

```sh
ip a s br-ex
```

Si elle n'a pas d'ip ou est down il faut les redonner pour forcer

```sh
sudo ip link set br-ex up
sudo ip a add 172.24.4.1/24 dev br-ex # l'IP doit correspondre à la passerelle du réseaux public
```

Et s'il y a un problème de nat ou de forward, il faut transformer l'hote en routeur

```sh
# allow ip forward
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
echo net.ipv4.ip_forward=1 | sudo tee /etc/sysctl.d/perso.conf

# create a nat
sudo apt install iptables
sudo iptables -t nat -A POSTROUTING -o ens33 -j MASQUERADE # l'interface dépend de ta vm
sudo apt install iptables-persistent    # répondre oui au deux question pour rendre les règles persistentes
```

## Terraform

voir dossier ``terraform``