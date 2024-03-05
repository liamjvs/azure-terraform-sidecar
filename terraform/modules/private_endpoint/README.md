<!-- BEGIN_TF_DOCS -->
# Private Endpoint

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
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| is\_manual\_connection | Is the connection manual | `bool` | `false` | no |
| location | Location of the resource group | `string` | n/a | yes |
| name | Name of the private endpoint | `string` | n/a | yes |
| private\_connection\_resource\_id | ID of the private connection resource | `string` | n/a | yes |
| private\_dns\_zone\_group\_name | Name of the private DNS zone group | `string` | `"default"` | no |
| private\_dns\_zone\_ids | Private DNS zone IDs | `list(string)` | `[]` | no |
| private\_service\_connection\_name | Name of the private service connection | `string` | `"private-service-connection"` | no |
| resource\_group\_name | Name of the resource group | `string` | n/a | yes |
| subnet\_id | ID of the subnet | `string` | n/a | yes |
| subresource\_names | Subresource names | `list(string)` | n/a | yes |
| tags | Tags for this resource | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->