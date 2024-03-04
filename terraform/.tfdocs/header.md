# azure-terraform-sidecar

[[_TOC_]]

## Description
This module deploys a Sidecar Terraform deployment into an Azure subscription. The deployment is a set of resources that are used to deploy a solution into Azure. It is extensible but the defaults will deploy:
- Resource Group
- [Linux Virtual Machine Scale Set](./modules/linux_virtual_machine_scale_set)
  - With [cloud-init](./cloud-init) configuration
- [Virtual Network](./modules/virtual_network)
- [Private DNS Zone](./modules/private_dns_zone)
- [Storage Account](./modules/storage_account)
- [Private Endpoint](./modules/private_endpoint)

It can be further customised to deploy additional resources, such as:
- [User Assigned Identity](./modules/user_assigned_identity)