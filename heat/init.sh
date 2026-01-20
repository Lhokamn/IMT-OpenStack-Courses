#! /usr/bin/env

set -euo pipefail

declare -r ID_PUBLICKNETWORK="$ID_ID_PUBLICNETWORK"
declare -r SSH_KEYNAME="$SSH_KEYNAME"
declare -r DB_PASSWORD="$DB_PASSWORD"
declare -r IMAGE="ubuntu-24.04"
declare -r FLAVOR="m1.small"


openstack stack create -t main.yml \
  --parameter public_net_id="$ID_PUBLICKNETWORK" \
  --parameter key_name="$SSH_KEYNAME" \
  --parameter db_password="$DB_PASSWORD" \
  --parameter image_name="$IMAGE" \
  --parameter flavor_name="$FLAVOR" \
  ma_stack_wordpress