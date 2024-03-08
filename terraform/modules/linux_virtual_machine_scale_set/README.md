<!-- BEGIN_TF_DOCS -->
# Linux Virtual Machine Scale Set

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 3.93.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.93.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine_scale_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine_scale_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_key | The public key of the local administrator account. | `string` | `null` | no |
| admin\_password | The password of the local administrator account. | `string` | `null` | no |
| admin\_username | The username of the local administrator account. | `string` | `"adminuser"` | no |
| automatic\_os\_upgrade\_policy | The automatic OS upgrade policy of the virtual machine scale set. | <pre>object({<br>    enable_automatic_os_upgrade = bool<br>    disable_automatic_rollback  = bool<br>  })</pre> | <pre>{<br>  "disable_automatic_rollback": false,<br>  "enable_automatic_os_upgrade": false<br>}</pre> | no |
| custom\_data | The custom data of the virtual machine scale set. If populated, it must be base64 encoded. | `string` | `null` | no |
| do\_not\_run\_extensions\_on\_overprovisioned\_vm | Specifies whether to run extensions on overprovisioned virtual machines. <br>  Recommend setting this to try if using this for Azure DevOps Agents as you may get a condition where a VM is deprovisioned but has received an Azure DevOps job. | `bool` | `false` | no |
| enable\_managed\_identity | Specifies whether a managed identity should be enabled for the virtual machine scale set. | `bool` | `true` | no |
| instances | The number of instances in the virtual machine scale set on initialy deployment. Currently, this property is added to be ignored post-deployment as Azure DevOps handles the instance count | `number` | `0` | no |
| location | The location/region where the resources are created. | `string` | n/a | yes |
| name | The name of the virtual machine scale set. | `string` | n/a | yes |
| nic\_name | The name of the network interface. | `string` | `null` | no |
| os\_disk\_caching | The caching of the operating system disk. | `string` | `"ReadWrite"` | no |
| os\_disk\_storage\_account\_type | The storage account type of the operating system disk. | `string` | `"Standard_LRS"` | no |
| resource\_group\_name | The name of the resource group in which to create the virtual machine scale set. | `string` | n/a | yes |
| single\_placement\_group | Specifies whether the scale set should be created with a single placement group. | `bool` | `false` | no |
| sku | The SKU of the virtual machine scale set. | `string` | n/a | yes |
| source\_image\_reference | The source image reference of the virtual machine scale set. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | n/a | yes |
| subnet\_id | The ID of the subnet where the virtual machine scale set is deployed. | `string` | n/a | yes |
| tags | Tags for this resource | `map(string)` | `{}` | no |
| upgrade\_mode | Specifies how virtual machine scale set should be upgraded. | `string` | `"Manual"` | no |
| user\_assigned\_identity\_ids | The IDs of the user assigned identities to assign to the virtual machine scale set. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_linux\_virtual\_machine\_scale\_set | n/a |
<!-- END_TF_DOCS -->