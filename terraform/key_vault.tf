

# [Key Vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)
resource "azurerm_key_vault" "kv" {
  name                = "kv-${var.resource_suffix}-${random_string.kv_name.id}"
  location            = azurerm_resource_group.posit.location
  resource_group_name = azurerm_resource_group.posit.name
  tags                = local.tags

  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
  purge_protection_enabled  = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["${chomp(data.http.myip.response_body)}/32"]
  }
}

# [Key Vault Secret](https://registry.terraform.io/providers/hashicorp/azurerm/latkey_vaultest/docs/resources/key_vault_secret)
resource "azurerm_key_vault_secret" "storage_account_key" {
  name         = "storage-account-${azurerm_storage_account.st.name}-key"
  value        = azurerm_storage_account.st.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.kv_sp_secrets_officer]
}

resource "azurerm_key_vault_secret" "vm_admin_password" {
  name         = "vm-admin-password"
  value        = random_password.vm.result
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_role_assignment.kv_sp_secrets_officer]
}
