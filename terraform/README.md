<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.83.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | 2.3.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.83.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.2 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_key_pair"></a> [azure\_key\_pair](#module\_azure\_key\_pair) | ./modules/ssh_public_key | n/a |
| <a name="module_linux_virtual_machine_scale_set"></a> [linux\_virtual\_machine\_scale\_set](#module\_linux\_virtual\_machine\_scale\_set) | ./modules/linux_virtual_machine_scale_set | n/a |
| <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone) | ./modules/private_dns_zone | n/a |
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | ./modules/private_endpoint | n/a |
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | ./modules/storage_account | n/a |
| <a name="module_user_assigned_identity"></a> [user\_assigned\_identity](#module\_user\_assigned\_identity) | ./modules/user_assigned_identity | n/a |
| <a name="module_virtual_network"></a> [virtual\_network](#module\_virtual\_network) | ./modules/virtual_network | n/a |

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
| <a name="input_authentication_method"></a> [authentication\_method](#input\_authentication\_method) | Post-deployment authentication method; either User, ServicePrincipal, SystemManagedIdentity or UserManagedIdentity. | `string` | `"User"` | no |
| <a name="input_backend_additional_principal_ids"></a> [backend\_additional\_principal\_ids](#input\_backend\_additional\_principal\_ids) | The additional principal IDs to grant access to the storage account. | `list(string)` | `[]` | no |
| <a name="input_backend_storage_account_container"></a> [backend\_storage\_account\_container](#input\_backend\_storage\_account\_container) | The container to store this Sidecar Terraform deployment into post-deployment. | `string` | `""` | no |
| <a name="input_backend_storage_account_containers"></a> [backend\_storage\_account\_containers](#input\_backend\_storage\_account\_containers) | The containers to create in the storage account. | `list(string)` | `[]` | no |
| <a name="input_backend_storage_account_name"></a> [backend\_storage\_account\_name](#input\_backend\_storage\_account\_name) | The name of the storage account to store the backend state file(s) on. Must be unique. | `string` | `null` | no |
| <a name="input_backend_storage_account_replication_type"></a> [backend\_storage\_account\_replication\_type](#input\_backend\_storage\_account\_replication\_type) | The type of replication to use for this storage account. | `string` | `"LRS"` | no |
| <a name="input_backend_storage_account_tier"></a> [backend\_storage\_account\_tier](#input\_backend\_storage\_account\_tier) | The tier to use for this storage account. | `string` | `"Standard"` | no |
| <a name="input_context"></a> [context](#input\_context) | The context of the deployment. | `string` | `"sidecar"` | no |
| <a name="input_deployment_choice"></a> [deployment\_choice](#input\_deployment\_choice) | Select the deployment choice. This can either be:<br>  - StorageAccount<br>    - A public storage account is created to store the backend state file(s).<br>  - AgentPool<br>    - A Virtual Network, Private DNS Zone, Linux Virtual Machine Scale Set, Storage Account and Private Endpoint are created with the appropriate Role-Based Access Control (RBAC) assignments. | `string` | `"StorageAccount"` | no |
| <a name="input_init"></a> [init](#input\_init) | If this is the first deployment of the solution. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the resources are created. | `string` | `"uksouth"` | no |
| <a name="input_private_deployment"></a> [private\_deployment](#input\_private\_deployment) | Make the solution private and only accessible via private endpoints. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the virtual network. | `string` | `null` | no |
| <a name="input_storage_account_private_endpoint_name"></a> [storage\_account\_private\_endpoint\_name](#input\_storage\_account\_private\_endpoint\_name) | The name of the private endpoint for the storage account. | `string` | `null` | no |
| <a name="input_subnet_private_endpoint_address_prefixes"></a> [subnet\_private\_endpoint\_address\_prefixes](#input\_subnet\_private\_endpoint\_address\_prefixes) | The address prefixes to use for the endpoint subnet. | `string` | `"10.0.1.0/24"` | no |
| <a name="input_subnet_private_endpoint_name"></a> [subnet\_private\_endpoint\_name](#input\_subnet\_private\_endpoint\_name) | The name of the endpoint subnet. | `string` | `null` | no |
| <a name="input_subnet_private_runner_name"></a> [subnet\_private\_runner\_name](#input\_subnet\_private\_runner\_name) | The name of the runner subnet. | `string` | `null` | no |
| <a name="input_subnet_runner_address_prefixes"></a> [subnet\_runner\_address\_prefixes](#input\_subnet\_runner\_address\_prefixes) | The address prefixes to use for the runner subnet. | `string` | `"10.0.0.0/24"` | no |
| <a name="input_user_assigned_identity_name"></a> [user\_assigned\_identity\_name](#input\_user\_assigned\_identity\_name) | The name of the user assigned managed identity | `string` | `""` | no |
| <a name="input_virtual_machine_scaleset_name"></a> [virtual\_machine\_scaleset\_name](#input\_virtual\_machine\_scaleset\_name) | The name of the virtual machine scale set. | `string` | `null` | no |
| <a name="input_virtual_machine_scaleset_use_azure_key_pair"></a> [virtual\_machine\_scaleset\_use\_azure\_key\_pair](#input\_virtual\_machine\_scaleset\_use\_azure\_key\_pair) | Whether to use an Azure key pair for the virtual machine scale set. | `bool` | `false` | no |
| <a name="input_virtual_machine_scaleset_use_random_password"></a> [virtual\_machine\_scaleset\_use\_random\_password](#input\_virtual\_machine\_scaleset\_use\_random\_password) | Whether to use a random password for the virtual machine scale set. | `bool` | `true` | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | The address space that is used the virtual network. | `list(string)` | <pre>[<br>  "10.0.0.0/23"<br>]</pre> | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the virtual network. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_name"></a> [container\_name](#output\_container\_name) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | n/a |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | n/a |
| <a name="output_use_azuread_auth"></a> [use\_azuread\_auth](#output\_use\_azuread\_auth) | n/a |
| <a name="output_use_msi"></a> [use\_msi](#output\_use\_msi) | n/a |
| <a name="output_virtual_machine_scaleset_id"></a> [virtual\_machine\_scaleset\_id](#output\_virtual\_machine\_scaleset\_id) | n/a |
<!-- END_TF_DOCS -->