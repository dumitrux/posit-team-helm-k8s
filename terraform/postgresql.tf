# [PostgreSQL Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server)
resource "azurerm_postgresql_server" "psql" {
  name                = "psql-${var.resource_suffix}-${random_string.psql_name.id}"
  location            = azurerm_resource_group.posit.location
  resource_group_name = azurerm_resource_group.posit.name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladmin"
  administrator_login_password = random_password.psql.result
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

# [PostgreSQL Database within a PostgreSQL Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_database)
resource "azurerm_postgresql_database" "psql" {
  name                = "positteam"
  resource_group_name = azurerm_resource_group.posit.name
  server_name         = azurerm_postgresql_server.psql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # lifecycle {
  #   prevent_destroy = true
  # }
}
