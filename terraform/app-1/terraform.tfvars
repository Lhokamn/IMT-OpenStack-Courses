#------------- AUTHENTIFICATION -------------
auth_url              = "http://172.16.37.140/identity"
user_name             = "imt-user"
password              = "imt"
project_name          = "imt-terraform"
user_domain_name      = "Default"
project_domain_name   = "Default"
region                = "RegionOne"


name_ssh_key = "imt-key-tf"
instance_name = "terraform-cirros"
private_network_cidr = "192.168.20.0/24"
network_name = "imt-lan"
subnet_name = "imt-sub"
router_name = "imt-tf-router"
sg_name = "sg-imt-tf"