locals {
  role_assignments = {
    for principal_id in var.principal_ids_role_assignment : principal_id => principal_id
  }
}