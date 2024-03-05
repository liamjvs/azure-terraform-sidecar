<!-- BEGIN_TF_DOCS -->
# SSH Public Key

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.93.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 1.10.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.public_key](https://registry.terraform.io/providers/azure/azapi/1.10.0/docs/resources/resource) | resource |
| [azapi_resource_action.gen](https://registry.terraform.io/providers/azure/azapi/1.10.0/docs/resources/resource_action) | resource |
| [random_pet.name](https://registry.terraform.io/providers/hashicorp/random/3.6.0/docs/resources/pet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The location/region where the resources are created. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The name of the resource group in which to create the SSH Key. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_key"></a> [public\_key](#output\_public\_key) | n/a |
<!-- END_TF_DOCS -->