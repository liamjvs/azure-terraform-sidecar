<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.83.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.83.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.9.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [time_sleep.sleep_for_role_assignment_to_take_effect](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_access_tier"></a> [account\_access\_tier](#input\_account\_access\_tier) | Defines the access tier to use for this storage account. | `string` | n/a | yes |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Defines the type of replication to use for this storage account. | `string` | n/a | yes |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Defines the Tier to use for this storage account. | `string` | n/a | yes |
| <a name="input_container_role_definition_name"></a> [container\_role\_definition\_name](#input\_container\_role\_definition\_name) | The name of the role definition to assign to the container. | `string` | `"Storage Blob Data Contributor"` | no |
| <a name="input_containers"></a> [containers](#input\_containers) | The containers to create in the storage account. | `set(string)` | <pre>[<br>  "container"<br>]</pre> | no |
| <a name="input_enable_https_traffic_only"></a> [enable\_https\_traffic\_only](#input\_enable\_https\_traffic\_only) | Whether or not to only allow HTTPS traffic to the storage account. | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the resources are created. | `string` | n/a | yes |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | The minimum TLS version to use for this storage account. | `string` | `"TLS1_2"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the storage account. | `string` | n/a | yes |
| <a name="input_principal_ids_role_assignment"></a> [principal\_ids\_role\_assignment](#input\_principal\_ids\_role\_assignment) | The IDs of the principals to assign the Storage Blob Data Contributor role to. | `map(string)` | n/a | yes |
| <a name="input_private_endpoint_network"></a> [private\_endpoint\_network](#input\_private\_endpoint\_network) | The ID of the subnet to use for the private endpoint. | <pre>object({<br>    virtual_network_id = optional(string)<br>    subnet             = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether or not public network access is allowed for this storage account. | `bool` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the storage account. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for this resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_role_assignment"></a> [azurerm\_role\_assignment](#output\_azurerm\_role\_assignment) | n/a |
| <a name="output_azurerm_storage_account"></a> [azurerm\_storage\_account](#output\_azurerm\_storage\_account) | n/a |
| <a name="output_azurerm_storage_container"></a> [azurerm\_storage\_container](#output\_azurerm\_storage\_container) | n/a |
<!-- END_TF_DOCS -->