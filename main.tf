provider "azurerm" {
  features {}
    client_id = "053b135a-afde-4cbf-9f28-5f4ed6ec0216"
    client_secret = "kNA8Q~0cTZnR8JJcjo~PUO5cnAtPylfOe.ibWcyC"
    tenant_id = "912ce2ae-d4c4-434f-89a0-7315884bb1b3"
    subscription_id = "a8997c0e-561a-4df1-a50d-16b5c207b16c"
}

module "resourcegroup" {
  source         = "./modules/resourcegroup"
  name           = var.name
  location       = var.location
}

module "networking" {
  source         = "./modules/networking"
  location       = module.resourcegroup.location_id
  resource_group = module.resourcegroup.resource_group_name
  vnetcidr       = var.vnetcidr
  websubnetcidr  = var.websubnetcidr
  appsubnetcidr  = var.appsubnetcidr
  dbsubnetcidr   = var.dbsubnetcidr
}

module "securitygroup" {
  source         = "./modules/securitygroup"
  location       = module.resourcegroup.location_id
  resource_group = module.resourcegroup.resource_group_name 
  web_subnet_id  = module.networking.websubnet_id
  app_subnet_id  = module.networking.appsubnet_id
  db_subnet_id   = module.networking.dbsubnet_id
}

module "compute" {
  source         = "./modules/compute"
  location = module.resourcegroup.location_id
  resource_group = module.resourcegroup.resource_group_name
  web_subnet_id = module.networking.websubnet_id
  app_subnet_id = module.networking.appsubnet_id
  web_host_name = var.web_host_name
  web_username = var.web_username
  web_os_password = var.web_os_password
  app_host_name = var.app_host_name
  app_username = var.app_username
  app_os_password = var.app_os_password
}

module "database" {
  source = "./modules/database"
  location = module.resourcegroup.location_id
  resource_group = module.resourcegroup.resource_group_name
  primary_database = var.primary_database
  primary_database_version = var.primary_database_version
  primary_database_admin = var.primary_database_admin
  primary_database_password = var.primary_database_password
}


module "azure_load_balancer" {
  source                     = "./modules/loadbalancer"
  public_ip_name             = "myPublicIP"
  location                   = "East US"
  resource_group_name        = "myResourceGroup"
  lb_name                    = "myLoadBalancer"
  backend_address_pool_name  = "myBackendAddressPool"
  probe_name                 = "myProbe"
  probe_request_path         = "/health"
  probe_port                 = 80
  lb_rule_name               = "myLbRule"
  frontend_port              = 80
  backend_port               = 80
}