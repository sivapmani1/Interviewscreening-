resource "azurerm_public_ip" "lb" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "bap" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = var.backend_address_pool_name
}

resource "azurerm_lb_probe" "probe" {
  name                = var.probe_name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  request_path        = var.probe_request_path
  port                = var.probe_port
}

resource "azurerm_lb_rule" "rule" {
  name                           = var.lb_rule_name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = var.frontend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "publicIPAddress"
  backend_address_pool_ids       = azurerm_lb_backend_address_pool.bap.id
  probe_id                       = azurerm_lb_probe.probe.id
}