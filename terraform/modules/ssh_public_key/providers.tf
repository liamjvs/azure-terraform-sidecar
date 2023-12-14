terraform {
  required_version = ">= 1.2.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5" # Replace with the desired version or version constraint
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.10.0"
    }
  }
}