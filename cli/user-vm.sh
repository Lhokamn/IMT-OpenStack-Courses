#! /usr/bin/env bash

set -euo pipefail

# --- Fonctions ---
print() {
    printf "[\e[32mINFO\e[0m] %s\n" "$1"
}

error() {
    printf "[\e[31mERROR\e[0m] %s\n" "$1" >&2
    exit "$2"
}

# Fonction générique pour créer une ressource si elle n'existe pas
safe_create() {
    local type=$1
    local name=$2
    shift 2
    if ! openstack "$type" show "$name" >/dev/null 2>&1; then
        print "Création du $type : $name"
        openstack "$type" create "$@" "$name" > /dev/null
    else
        print "Le $type '$name' existe déjà."
    fi
}

# --- Configuration ---
declare -r SSH_PUBLIC_KEY_PATH=$HOME/.ssh/id_rsa_openstack.pub
declare -r SSH_KEY_NAME="imt-ansible-key"
declare -r NETWORK_NAME="imt-cli-lan"
declare -r NETWORK_CIDR="192.168.10.0/24"
declare -r NETWORK_SUBNET="imt-cli-sub"
declare -r ROUTER_NAME="imt-router"
declare -r PUBLIC_NETWORK="public"
declare -r IMAGE_ID="cirros-0.6.3-x86_64-disk"
declare -r FLAVOR="m1.tiny"
declare -r INSTANCE_NAME="imt-instance-cli"

# --- Vérification Variables ---
vars_to_check=(
    "OS_PROJECT_DOMAIN_ID" "OS_USER_DOMAIN_ID" "OS_PROJECT_NAME"
    "OS_TENANT_NAME" "OS_USERNAME" "OS_PASSWORD"
    "OS_AUTH_URL" "OS_IDENTITY_API_VERSION"
)
for var in "${vars_to_check[@]}"; do
    if [ -z "${!var:-}" ]; then error "Variable $var absente." 1; fi
done

# --- Exécution ---

# 1. Clé SSH
if ! openstack keypair show "$SSH_KEY_NAME" >/dev/null 2>&1; then
    print "Importation de la clé SSH..."
    openstack keypair create --public-key "$SSH_PUBLIC_KEY_PATH" "$SSH_KEY_NAME" > /dev/null
fi

# 2. Groupes de sécurité
safe_create "security group" "sec-http" --description "Autorise HTTP"
safe_create "security group" "sec-icmp" --description "Autorise Ping"
safe_create "security group" "sec-ssh"  --description "Autorise SSH"

print "Vérification des règles..."
openstack security group rule create --protocol tcp --dst-port 80:80 sec-http 2>/dev/null || true
openstack security group rule create --protocol tcp --dst-port 443:443 sec-http 2>/dev/null || true
openstack security group rule create --protocol icmp sec-icmp 2>/dev/null || true
openstack security group rule create --protocol tcp --dst-port 22:22 sec-ssh 2>/dev/null || true

# 3. Réseau et Routage
safe_create "network" "$NETWORK_NAME"
safe_create "subnet" "$NETWORK_SUBNET" --network "$NETWORK_NAME" --subnet-range "$NETWORK_CIDR"
safe_create "router" "$ROUTER_NAME"

print "Configuration du routage..."
openstack router set --external-gateway "$PUBLIC_NETWORK" "$ROUTER_NAME" 2>/dev/null || true
openstack router add subnet "$ROUTER_NAME" "$NETWORK_SUBNET" 2>/dev/null || true

# 4. Instance
if ! openstack server show "$INSTANCE_NAME" >/dev/null 2>&1; then
    print "Lancement de l'instance '$INSTANCE_NAME'..."
    openstack server create --flavor "$FLAVOR" \
        --image "$IMAGE_ID" \
        --network "$NETWORK_NAME" \
        --key-name "$SSH_KEY_NAME" \
        --security-group sec-http \
        --security-group sec-icmp \
        --security-group sec-ssh \
        "$INSTANCE_NAME" > /dev/null
    print "Pause de 10s pour l'initialisation..."
    sleep 10
else
    print "L'instance '$INSTANCE_NAME' est déjà active."
fi

# 5. IP Flottante
# On ne crée une IP que si l'instance n'en a pas déjà une
if ! openstack server show "$INSTANCE_NAME" -f value -c addresses | grep -q "$PUBLIC_NETWORK" ; then
    print "Attribution d'une nouvelle IP flottante..."
    FLOATING_IP=$(openstack floating ip create "$PUBLIC_NETWORK" -f value -c floating_ip_address)
    openstack server add floating ip "$INSTANCE_NAME" "$FLOATING_IP"
else
    FLOATING_IP=$(openstack server show "$INSTANCE_NAME" -f json | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | tail -n 1)
    print "L'instance a déjà une IP flottante associée."
fi

# --- Résumé ---
echo "------------------------------------------------"
print "Déploiement terminé avec succès !"
print "IP Publique : $FLOATING_IP"
print "Accès : ssh -i ${SSH_PUBLIC_KEY_PATH%.*} cirros@$FLOATING_IP"
echo "------------------------------------------------"