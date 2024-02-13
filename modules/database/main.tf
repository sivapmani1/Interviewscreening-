resource "azurerm_mysql_server" "primary" {
    name = var.primary_database
    ssl_enforcement_enabled = true
    ssl_minimal_tls_version_enforced  = "TLS1_2"
    resource_group_name = var.resource_group
    sku_name = "B_Gen5_2"
    location = var.location
    version = var.primary_database_version
    administrator_login = var.primary_database_admin
    administrator_login_password = var.primary_database_password
}

resource "azurerm_mysql_database" "db" {
  name                = "db"
  resource_group_name = var.resource_group
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
  server_name         = azurerm_mysql_server.primary.name
}

