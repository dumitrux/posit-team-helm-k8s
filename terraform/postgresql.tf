# [PostgreSQL Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_server)
resource "azurerm_postgresql_server" "example" {
  name                = "postgresql-server-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = "B_Gen5_2"

  storage_mb                   = 5120
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true

  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement_enabled      = true
}

# [PostgreSQL Database within a PostgreSQL Server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_database)
resource "azurerm_postgresql_database" "example" {
  name                = "exampledb"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "English_United States.1252"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}
