<!-- BEGIN_TF_DOCS -->
# Storage Account

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2.0 |
| azurerm | >= 3.93.0 |
| time | >= 0.9.2 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.93.0 |
| time | >= 0.9.2 |

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
| account\_replication\_type | Defines the type of replication to use for this storage account. | `string` | n/a | yes |
| account\_tier | Defines the Tier to use for this storage account. | `string` | n/a | yes |
| container\_role\_definition\_name | The name of the role definition to assign to the container. | `string` | `"Storage Blob Data Contributor"` | no |
| containers | The containers to create in the storage account. | `set(string)` | <pre>[<br>  "container"<br>]</pre> | no |
| enable\_https\_traffic\_only | Whether or not to only allow HTTPS traffic to the storage account. | `bool` | `true` | no |
| location | The location/region where the resources are created. | `string` | n/a | yes |
| min\_tls\_version | The minimum TLS version to use for this storage account. | `string` | `"TLS1_2"` | no |
| name | The name of the storage account. | `string` | n/a | yes |
| principal\_ids\_role\_assignment | The IDs of the principals to assign the Storage Blob Data Contributor role to. | `map(string)` | n/a | yes |
| public\_network\_access\_enabled | Whether or not public network access is allowed for this storage account. | `bool` | n/a | yes |
| resource\_group\_name | The name of the resource group in which to create the storage account. | `string` | n/a | yes |
| shared\_access\_key\_enabled | Whether or not to enable shared access keys for this storage account. | `bool` | `false` | no |
| tags | Tags for this resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_role\_assignment | n/a |
| azurerm\_storage\_account | n/a |
| azurerm\_storage\_container | n/a |
<!-- END_TF_DOCS -->