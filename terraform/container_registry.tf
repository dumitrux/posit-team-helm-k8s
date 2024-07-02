# [Container Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)
resource "azurerm_container_registry" "cr" {
  name                = "cr${replace(var.resource_suffix, "-", "")}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = local.tags

  sku           = "Standard"
  admin_enabled = false

  identity {
    type = "SystemAssigned"
  }

}
