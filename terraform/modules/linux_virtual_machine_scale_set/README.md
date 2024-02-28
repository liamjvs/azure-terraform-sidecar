<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.19.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.19.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_key"></a> [admin\_key](#input\_admin\_key) | The public key of the local administrator account. | `string` | `null` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | The password of the local administrator account. | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | The username of the local administrator account. | `string` | `"adminuser"` | no |
| <a name="input_automatic_os_upgrade_policy"></a> [automatic\_os\_upgrade\_policy](#input\_automatic\_os\_upgrade\_policy) | The automatic OS upgrade policy of the virtual machine scale set. | <pre>object({<br>    enable_automatic_os_upgrade = bool<br>    disable_automatic_rollback  = bool<br>  })</pre> | <pre>{<br>  "disable_automatic_rollback": false,<br>  "enable_automatic_os_upgrade": false<br>}</pre> | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | The custom data of the virtual machine scale set. If populated, it must be base64 encoded. | `string` | `null` | no |
| <a name="input_do_not_run_extensions_on_overprovisioned_vm"></a> [do\_not\_run\_extensions\_on\_overprovisioned\_vm](#input\_do\_not\_run\_extensions\_on\_overprovisioned\_vm) | Specifies whether to run extensions on overprovisioned virtual machines. <br>  Recommend setting this to try if using this for Azure DevOps Agents as you may get a condition where a VM is deprovisioned but has received an Azure DevOps job. | `bool` | `false` | no |
| <a name="input_enable_managed_identity"></a> [enable\_managed\_identity](#input\_enable\_managed\_identity) | Specifies whether a managed identity should be enabled for the virtual machine scale set. | `bool` | `true` | no |
| <a name="input_instances"></a> [instances](#input\_instances) | The number of instances in the virtual machine scale set. | `number` | `0` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the resources are created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the virtual machine scale set. | `string` | n/a | yes |
| <a name="input_nic_name"></a> [nic\_name](#input\_nic\_name) | The name of the network interface. | `string` | `null` | no |
| <a name="input_os_disk_caching"></a> [os\_disk\_caching](#input\_os\_disk\_caching) | The caching of the operating system disk. | `string` | `"ReadWrite"` | no |
| <a name="input_os_disk_storage_account_type"></a> [os\_disk\_storage\_account\_type](#input\_os\_disk\_storage\_account\_type) | The storage account type of the operating system disk. | `string` | `"Standard_LRS"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the virtual machine scale set. | `string` | n/a | yes |
| <a name="input_single_placement_group"></a> [single\_placement\_group](#input\_single\_placement\_group) | Specifies whether the scale set should be created with a single placement group. | `bool` | `false` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the virtual machine scale set. | `string` | n/a | yes |
| <a name="input_source_image_reference"></a> [source\_image\_reference](#input\_source\_image\_reference) | The source image reference of the virtual machine scale set. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet where the virtual machine scale set is deployed. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for this resource | `map(string)` | `{}` | no |
| <a name="input_upgrade_mode"></a> [upgrade\_mode](#input\_upgrade\_mode) | Specifies how virtual machine scale set should be upgraded. | `string` | `"Manual"` | no |
| <a name="input_user_assigned_identity_ids"></a> [user\_assigned\_identity\_ids](#input\_user\_assigned\_identity\_ids) | The IDs of the user assigned identities to assign to the virtual machine scale set. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_linux_virtual_machine_scale_set"></a> [azurerm\_linux\_virtual\_machine\_scale\_set](#output\_azurerm\_linux\_virtual\_machine\_scale\_set) | n/a |
<!-- END_TF_DOCS -->