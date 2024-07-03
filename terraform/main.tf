terraform {
  required_version = "~> 1.0"

  # [Backend azurerm](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm)
  backend "azurerm" {}

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    # https://registry.terraform.io/providers/hashicorp/http/latest
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    # https://registry.terraform.io/providers/hashicorp/random/latest
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# [Data AzureRM provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config)
data "azurerm_client_config" "current" {}

# [Resource Group](https://registry.terraform.io/providers/hashicorp/Azurerm/latest/docs/resources/resource_group)
resource "azurerm_resource_group" "posit" {
  name     = "rg-${var.resource_suffix}"
  location = var.location
  tags     = local.tags
}
