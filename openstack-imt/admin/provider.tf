terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

provider "openstack" {
  auth_url            = var.auth_url
  user_name           = var.user_name
  password            = var.password
  tenant_name         = var.project_name
  user_domain_name    = var.user_domain_name
  project_domain_name = var.project_domain_name
  region              = var.region
}