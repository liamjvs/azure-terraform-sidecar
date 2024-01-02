resource "random_pet" "name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource" "public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.name.id
  location  = var.location
  parent_id = var.resource_group_id
}

resource "azapi_resource_action" "gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.public_key.id
  action      = "generateKeyPair"
  method      = "POST"
  response_export_values = [
    "publicKey",
    "privateKey"
  ]
}