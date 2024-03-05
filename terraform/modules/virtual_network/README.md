<!-- BEGIN_TF_DOCS -->
# Virtual Network and Subnet(s)

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
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| address\_space | The address space that is used the virtual network. | `list(string)` | n/a | yes |
| location | The location/region where the resources are created. | `string` | n/a | yes |
| name | The name of the Virtual Network. | `string` | n/a | yes |
| resource\_group\_name | The name of the resource group in which to create the Virtual Network. | `string` | n/a | yes |
| subnets | The subnets that are used the virtual network. | <pre>map(object({<br>    address_prefixes                      = list(string)<br>    private_endpoint_network_policies     = optional(bool)<br>    private_link_service_network_policies = optional(bool)<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_subnet | n/a |
| azurerm\_virtual\_network | n/a |
<!-- END_TF_DOCS -->