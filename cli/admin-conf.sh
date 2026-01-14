#! /usr/bin/env bash

set -euo pipefail

print() {
    printf "%s\n" "$1"
}

error() {
    print "Error: $1"
    exit "$2"
}

# Variables de configuration
declare -r DOMAIN="default"
declare -r DOMAIN_DESCRIPTION="IMT CLI creation project"
declare -r PROJECT_NAME="imt-cli"
declare -r USER_NAME="imt-user"
declare -r USER_PASSWORD="imt"

vars_to_check=(
    "OS_PROJECT_DOMAIN_ID"
    "OS_USER_DOMAIN_ID"
    "OS_PROJECT_NAME"
    "OS_TENANT_NAME"
    "OS_USERNAME"
    "OS_PASSWORD"
    "OS_AUTH_URL"
    "OS_IDENTITY_API_VERSION"
)

# Vérification des variables d'environnement
for var in "${vars_to_check[@]}"; do
    if [ -z "${!var:-}" ]; then
        error "Variable $var is not set or is empty." 1
    fi
done

# 1. Test des credentials
print "Checking credentials..."
openstack token issue > /dev/null || error "Credentials not good" 2

# 2. Création du projet
# Ajout de "" autour des variables et de --or-show pour éviter l'erreur si existe déjà
print "Creating project $PROJECT_NAME..."
openstack project create --domain "$DOMAIN" \
    --description "$DOMAIN_DESCRIPTION" \
    --or-show \
    "$PROJECT_NAME" || error "Impossible to create new project $PROJECT_NAME" 3

# 3. Création de l'utilisateur
# Correction : Ajout de $USER_NAME à la fin
print "Creating user $USER_NAME..."
openstack user create --domain "$DOMAIN" \
    --password "$USER_PASSWORD" \
    --or-show \
    "$USER_NAME" || error "Impossible to create the user: $USER_NAME" 4

# 4. Ajout du rôle
print "Assigning role 'member' to $USER_NAME on $PROJECT_NAME..."
openstack role add --project "$PROJECT_NAME" --user "$USER_NAME" member || error "Failed to add role" 5

print "Setup completed successfully."