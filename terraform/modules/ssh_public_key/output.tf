output "public_key" {
  value     = jsondecode(azapi_resource_action.gen.output).publicKey
  sensitive = true
}