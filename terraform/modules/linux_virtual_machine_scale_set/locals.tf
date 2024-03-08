locals {
  nic_name = coalesce(var.nic_name, "${var.name}-nic")
}