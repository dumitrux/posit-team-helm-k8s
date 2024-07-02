# [Role Assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)

# ACR
resource "azurerm_role_assignment" "acr_aks_pull" {
  scope                = azurerm_container_registry.cr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# AKS
resource "azurerm_role_assignment" "aks_users" {
  for_each = var.role_assignments.aks

  description                      = each.value.description
  principal_id                     = each.value.principal_id
  principal_type                   = each.value.principal_type
  role_definition_name             = each.value.role_definition_name
  scope                            = azurerm_kubernetes_cluster.aks.id
  skip_service_principal_aad_check = each.value.skip_service_principal_check
}

# Key Vault
resource "azurerm_role_assignment" "kv_users" {
  for_each = var.role_assignments.key_vault

  description                      = each.value.description
  principal_id                     = each.value.principal_id
  principal_type                   = each.value.principal_type
  role_definition_name             = each.value.role_definition_name
  scope                            = azurerm_key_vault.kv.id
  skip_service_principal_aad_check = each.value.skip_service_principal_check
}

resource "azurerm_role_assignment" "kv_sp_secrets_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
