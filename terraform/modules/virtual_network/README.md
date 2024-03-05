<!-- BEGIN_TF_DOCS -->
# Virtual Network and Subnet(s)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.93.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.93.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space that is used the virtual network. | `list(string)` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location/region where the resources are created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Virtual Network. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the Virtual Network. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The subnets that are used the virtual network. | <pre>map(object({<br>    address_prefixes                      = list(string)<br>    private_endpoint_network_policies     = optional(bool)<br>    private_link_service_network_policies = optional(bool)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_azurerm_subnet"></a> [azurerm\_subnet](#output\_azurerm\_subnet) | n/a |
| <a name="output_azurerm_virtual_network"></a> [azurerm\_virtual\_network](#output\_azurerm\_virtual\_network) | n/a |
<!-- END_TF_DOCS -->