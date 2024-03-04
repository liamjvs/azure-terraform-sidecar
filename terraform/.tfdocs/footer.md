### Resource Names
Module `azu-comp-tf-resourcenames` will be utilized to generate the resource name, which can consist of `project`,`stage`,`region`,`context` and `instance` like in the example usage below.

### Example Usage - First Run Enabled

```json
module "sidecar_test" {
  source   = "../../"
  location = local.location
  project  = local.project
  stage    = local.stage
  context  = local.context
  instance = local.instance
  firstrun = true
}
```

### Example Usage - First Run Disabled

```json
module "sidecar_test" {
  source   = "../../"
  location = local.location
  project  = local.project
  stage    = local.stage
  context  = local.context
  instance = local.instance
  firstrun = false
}
```

### Changelog

- [azu-solu-tf-sidecar](CHANGELOG.md)

### References

### Microsoft Docs
- [Azure Service Level Agreement](https://azure.microsoft.com/en-us/support/legal/sla/summary)

### Terraform Docs
- [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)