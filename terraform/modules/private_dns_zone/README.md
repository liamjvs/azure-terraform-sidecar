<!-- BEGIN_TF_DOCS -->
# Private DNS Zone

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
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the Private DNS Zone. | `string` | n/a | yes |
| resource\_group\_name | The name of the resource group in which to create the virtual network. | `string` | n/a | yes |
| tags | Tags for this resource | `map(string)` | `{}` | no |
| virtual\_network\_ids | The IDs of the virtual networks to link to the private DNS zone. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_private\_dns\_zone | n/a |
<!-- END_TF_DOCS -->