<!-- BEGIN_TF_DOCS -->
# User Assigned Identity

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
| [azurerm_user_assigned_identity.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| location | Location of the resource group | `string` | n/a | yes |
| name | Name of the user assigned identity | `string` | n/a | yes |
| resource\_group\_name | Name of the resource group | `string` | n/a | yes |
| tags | Tags for this resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| azurerm\_user\_assigned\_identity | n/a |
<!-- END_TF_DOCS -->