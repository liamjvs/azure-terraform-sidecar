terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.93.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.10.0"
    }
    random_pet = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}