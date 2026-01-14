# 2. Identity (Projet, User, Role) 
resource "openstack_identity_project_v3" "project_1" {
  name = var.new_project_name
}

resource "openstack_identity_user_v3" "user_1" {
  name               = var.user_project_name
  default_project_id = openstack_identity_project_v3.project_1.id
  password           = var.user_project_password
  
  # [cite_start]Attendre que le projet soit créé [cite: 11]
  depends_on = [openstack_identity_project_v3.project_1]
}

resource "openstack_identity_role_assignment_v3" "role_assignment" {
  user_id    = openstack_identity_user_v3.user_1.id
  project_id = openstack_identity_project_v3.project_1.id
  role_id    = var.id_member_openstack

  depends_on = [
    openstack_identity_project_v3.project_1,
    openstack_identity_user_v3.user_1
  ]
}