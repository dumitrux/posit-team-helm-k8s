# [Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
resource "azurerm_storage_account" "st" {
  name                = "st${replace(var.resource_suffix, "-", "")}"
  location            = azurerm_resource_group.posit.location
  resource_group_name = azurerm_resource_group.posit.name
  tags                = local.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
  # public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = ["${chomp(data.http.myip.response_body)}"]
    virtual_network_subnet_ids = [azurerm_subnet.workload.id, azurerm_subnet.aks.id]
  }
}

# [Storage File Share](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share)
resource "azurerm_storage_share" "rstudio" {
  name                 = "rstudio-fileshare"
  storage_account_name = azurerm_storage_account.st.name
  quota                = 100
}

resource "azurerm_storage_share" "xdl" {
  name                 = "xdl"
  storage_account_name = azurerm_storage_account.st.name
  quota                = 100
}
