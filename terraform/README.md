<!-- BEGIN_TF_DOCS -->
# azure-terraform-sidecar

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2.0 |
| azapi | 1.10.0 |
| azurerm | >= 3.83.0 |
| cloudinit | 2.3.2 |
| random | ~> 3.5 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.83.0 |
| cloudinit | 2.3.2 |
| random | ~> 3.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| azure\_key\_pair | ./modules/ssh_public_key | n/a |
| linux\_virtual\_machine\_scale\_set | ./modules/linux_virtual_machine_scale_set | n/a |
| private\_dns\_zone | ./modules/private_dns_zone | n/a |
| private\_endpoint | ./modules/private_endpoint | n/a |
| storage\_account | ./modules/storage_account | n/a |
| user\_assigned\_identity | ./modules/user_assigned_identity | n/a |
| virtual\_network | ./modules/virtual_network | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [cloudinit_config.multipart](https://registry.terraform.io/providers/hashicorp/cloudinit/2.3.2/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| authentication\_method | Post-deployment authentication method; either User, ServicePrincipal, SystemManagedIdentity or UserManagedIdentity. | `string` | `"User"` | no |
| backend\_additional\_principal\_ids | The additional principal IDs to grant access to the storage account. | `list(string)` | `[]` | no |
| backend\_storage\_account\_container | The container to store this Sidecar Terraform deployment into post-deployment. | `string` | `""` | no |
| backend\_storage\_account\_containers | The containers to create in the storage account. | `list(string)` | `[]` | no |
| backend\_storage\_account\_name | The name of the storage account to store the backend state file(s) on. Must be unique. | `string` | `null` | no |
| backend\_storage\_account\_replication\_type | The type of replication to use for this storage account. | `string` | `"LRS"` | no |
| backend\_storage\_account\_tier | The tier to use for this storage account. | `string` | `"Standard"` | no |
| context | The context of the deployment. | `string` | `"sidecar"` | no |
| deployment\_choice | Select the deployment choice. This can either be:<br>  - StorageAccount: A public storage account is created to store the backend state file(s).<br>  - AgentPool: A Virtual Network, Private DNS Zone, VMSS, Storage Account and Private Endpoint are created with the appropriate RBAC assignments. | `string` | `"StorageAccount"` | no |
| init | If this is the first deployment of the solution. | `bool` | `false` | no |
| location | The location/region where the resources are created. | `string` | `"uksouth"` | no |
| private\_deployment | Make the solution private and only accessible via private endpoints. | `bool` | `false` | no |
| resource\_group\_name | The name of the resource group in which to create the virtual network. | `string` | `null` | no |
| storage\_account\_private\_endpoint\_name | The name of the private endpoint for the storage account. | `string` | `null` | no |
| subnet\_private\_endpoint\_address\_prefixes | The address prefixes to use for the endpoint subnet. | `string` | `"10.0.1.0/24"` | no |
| subnet\_private\_endpoint\_name | The name of the endpoint subnet. | `string` | `null` | no |
| subnet\_private\_runner\_name | The name of the runner subnet. | `string` | `null` | no |
| subnet\_runner\_address\_prefixes | The address prefixes to use for the runner subnet. | `string` | `"10.0.0.0/24"` | no |
| user\_assigned\_identity\_name | The name of the user assigned managed identity | `string` | `""` | no |
| virtual\_machine\_scaleset\_name | The name of the virtual machine scale set. | `string` | `null` | no |
| virtual\_machine\_scaleset\_use\_azure\_key\_pair | Whether to use an Azure key pair for the virtual machine scale set. | `bool` | `false` | no |
| virtual\_machine\_scaleset\_use\_random\_password | Whether to use a random password for the virtual machine scale set. | `bool` | `true` | no |
| virtual\_network\_address\_space | The address space that is used the virtual network. | `list(string)` | <pre>[<br>  "10.0.0.0/23"<br>]</pre> | no |
| virtual\_network\_name | The name of the virtual network. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| container\_name | n/a |
| resource\_group\_name | n/a |
| storage\_account\_name | n/a |
| subscription\_id | n/a |
| tenant\_id | n/a |
| use\_azuread\_auth | n/a |
| use\_msi | n/a |
| virtual\_machine\_scaleset\_id | n/a |
<!-- END_TF_DOCS -->