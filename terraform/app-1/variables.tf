######################################################
# 1. AUTHENTICATION
######################################################

variable "auth_url" {
  type        = string
  description = "Keystone v3 authentication URL (OS_AUTH_URL)."
}

variable "user_name" {
  type        = string
  description = "OpenStack username (OS_USERNAME)."
}

variable "password" {
  type        = string
  description = "OpenStack user password (OS_PASSWORD)."
  sensitive   = true
}

variable "project_name" {
  type        = string
  description = "OpenStack project / tenant name (OS_PROJECT_NAME)."
}

variable "user_domain_name" {
  type        = string
  description = "OpenStack user domain (OS_USER_DOMAIN_NAME)."
}

variable "project_domain_name" {
  type        = string
  description = "OpenStack project domain (OS_PROJECT_DOMAIN_NAME)."
}

variable "region" {
  type = string 
  description = "OpenStack Region "
}


######################################################
# 1. ssh
######################################################

variable "ssh_public_key_path" {
  type        = string
  description = "Chemin local vers la clé privée pour SSH"
  default     = "/home/ubuntu/.ssh/id_rsa_openstack.pub"
}

variable "name_ssh_key" {
  type = string
  description = "name of ssh-key in OpenStack"
}

######################################################
# 2. Environment configuration
######################################################

variable "private_network_cidr" {
  type    = string
  description = "network for the project"
}

variable "network_name" {
    type = string
    description = "name of the network"
}

variable "subnet_name" {
    type = string
    description = "name of the subnet of the network"
}

variable "external_network_name" {
  type    = string
  default = "Public" # À modifier selon le nom du réseau public de votre fournisseur
  description = "Name of the public network of your OpenStack"
}

variable "router_name" {
  type = string
  description = "Name of the routeur for your network"
}

variable "sg_name" {
  type = string
  description = "name of your security group"
}

variable "instance_name" {
  type    = string
  description = "Name of the new VM"
}

variable "image_name" {
  type    = string
  default = "cirros-0.6.3-x86_64-disk"
}

variable "flavor_name" {
  type    = string
  default = "m1.tiny"
  description = "flavor for the VM instance. Default: m1.tiny "
}


