# [Container Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)
resource "azurerm_container_registry" "cr" {
  name                = "cr${replace(var.resource_suffix, "-", "")}"
  location            = azurerm_resource_group.posit.location
  resource_group_name = azurerm_resource_group.posit.name
  tags                = local.tags

  sku           = "Standard"
  admin_enabled = false

  identity {
    type = "SystemAssigned"
  }

}
