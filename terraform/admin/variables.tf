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

variable "new_project_name" {
  type = string
  description = "Name of the new project"
}

variable "user_project_name" {
  type = string
  description = "Name of the user who will be member of the project"
}

variable "user_project_password" {
  type = string
  sensitive = true
  description = "Password of the User"
}

variable "id_member_openstack" {
  type = string
  sensitive = true
  description = "id of member group in your openstack"
}