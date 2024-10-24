terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.5.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-staticsite-lb-multicloud-tf-williamiac"
    storage_account_name = "staticsitelbtfwilliamiac"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  resource_provider_registrations = "none"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# 456