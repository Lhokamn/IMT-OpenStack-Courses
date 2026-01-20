# IMT-OpenStack-Courses

Dépot github de [Corentin CLaudel](mailto:corentin.claudel@etu.mines-ales.fr) dans le cadre du cours d'OpenStack dispensé au sein de l'IMT Mines Alès

Pour les scripts [Ansible](./ansible/), [CLI](./cli/) et [Terraform](./terraform/), le but est:
- Admin:
    - Créer un projet
    - Créer un utilisateur
    - Ajouter l'utilsiateur en tant que membre du projet
- Infra
    - Créer un réseau privé
    - Connecter le réseau privé au réseau public
    - Créer des règles de sécurités aui autorise: ``http``,``https`` et le ping
    - Ajouter une clé ssh dans le projet
    - Démarrer une VM
    - Attribuer une IP flottante a cette VM

pour le script CLI et HEAT il faut créer les fichier ``.admin-openrc`` et ``.user-openrc`` avec les bonnes variables d'environments et ensuite les sourcer

```openrc
export OS_USERNAME=
export OS_PASSWORD=
export OS_PROJECT_NAME=
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=
export OS_IDENTITY_API_VERSION=3
```

```sh
# ansible launch
cd ansible
ansible-playbook -i inventory.ini site.yml

# cli launch
chmod 744 cli/*
## source admin credential
./cli/admin-conf.sh

## source user credential
./cli/user-vm.sh

# terraform launch
cd terraform/admin
terraform init
terraform plan
terraform apply -auto-approve
```

Pour le Script [Heat](./heat/), le but est de déployer un wordpress avec une base de donnée SQL, un réseau privé, un load balancer (Octavia), mettre les bons groupes de sécurités

Pour lancer le script heat, il faut utiliser la commande suivante
```sh
openstack stack create -t main.yml \                                                         
  --parameter public_net_id="$ID_PUBLICNETWORK" \
  --parameter key_name="$SSH_KEYNAME" \
  --parameter db_password="$DB_PASSWORD" \
  --parameter image_name="$IMAGE" \
  --parameter flavor_name="$FLAVOR" \
  ma_stack_wordpress
```