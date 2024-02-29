terraform {
  required_version = ">= 1.2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.93.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.2"
    }
  }
}