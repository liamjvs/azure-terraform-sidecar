terraform {
  required_version = ">= 1.2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.83.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5" # Replace with the desired version or version constraint
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.2"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.10.0"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine_scale_set {
      roll_instances_when_required = tru
    }
  }
  skip_provider_registration = true
  storage_use_azuread        = true
}

provider "azapi" {
}