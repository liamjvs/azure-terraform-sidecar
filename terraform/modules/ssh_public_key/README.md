<!-- BEGIN_TF_DOCS -->
# SSH Public Key

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azapi | 1.10.0 |
| azurerm | >= 3.93.0 |
| random | 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| azapi | 1.10.0 |
| random | 3.6.0 |

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
| location | The location/region where the resources are created. | `string` | n/a | yes |
| resource\_group\_id | The name of the resource group in which to create the SSH Key. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| public\_key | n/a |
<!-- END_TF_DOCS -->