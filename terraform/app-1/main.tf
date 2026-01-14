# --- 1. Clé SSH & Network ---
resource "openstack_compute_keypair_v2" "my_keypair" {
  name       = "my-project-key"
  public_key = file(var.ssh_public_key_path)
}

resource "openstack_networking_network_v2" "private_network" {
  name           = "private-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "private-subnet"
  network_id = openstack_networking_network_v2.private_network.id
  cidr       = var.private_network_cidr
  ip_version = 4
}

# --- 2. Routage vers l'extérieur ---

# Recherche du réseau externe
data "openstack_networking_network_v2" "external_net" {
  name = var.external_network_name
}

# Création du routeur
resource "openstack_networking_router_v2" "router" {
  name                = var.router_name
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external_net.id
}

# Jonction du routeur au subnet privé (Interface)
resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id

  depends_on = [
    openstack_networking_router_v2.router,
    openstack_networking_subnet_v2.private_subnet
  ]
}

# --- 3. Security Groups (SSH, HTTP, HTTPS, ICMP) ---
resource "openstack_networking_secgroup_v2" "secgroup_main" {
  name        = var.sg_name
  description = "Rules for Web, ICMP and SSH"
}

resource "openstack_networking_secgroup_rule_v2" "rules" {
  for_each = {
    ssh   = { port = 22, proto = "tcp" }
    http  = { port = 80, proto = "tcp" }
    https = { port = 443, proto = "tcp" }
    icmp  = { port = 0,  proto = "icmp" } # Port 0 car ICMP n'utilise pas de ports TCP
  }

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = each.value.proto
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup_main.id
}

# --- 4. Start VM ---
resource "openstack_compute_instance_v2" "web_server" {
  name            = var.instance_name
  image_name      = var.image_name
  flavor_name     = var.flavor_name
  key_pair        = openstack_compute_keypair_v2.my_keypair.name
  security_groups = [openstack_networking_secgroup_v2.secgroup_main.name]

  network {
    uuid = openstack_networking_network_v2.private_network.id
  }

  depends_on = [
    openstack_networking_router_interface_v2.router_interface,
    openstack_networking_secgroup_v2.secgroup_main
  ]
}

# --- 5. IP Flottante ---

# Création de l'IP
resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.external_network_name
}

# Association de l'IP à la VM
resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.web_server.id

  depends_on = [
    openstack_compute_instance_v2.web_server,
    openstack_networking_floatingip_v2.fip
  ]
}

# Output pour récupérer l'IP facilement
output "vm_public_ip" {
  value = openstack_networking_floatingip_v2.fip.address
}