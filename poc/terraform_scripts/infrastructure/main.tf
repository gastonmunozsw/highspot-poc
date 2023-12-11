locals {
  subnets_address = cidrsubnets(var.network_space, 3, 3, 3, 3, 3, 3, 3)
  scale_sets      = length(local.subnets_address) - 1
  private_ip      = cidrhost(local.subnets_address[0], 4)
  ports           = [3000, 3001, 3002, 3003, 3004]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "naming" {
  source       = "../modules/naming"
  product_area = "hsi"
  environment  = var.environment
  location     = var.location
  generator = {
    domain = {
      resource_group            = 1
      virtual_network           = 1
      subnet                    = length(local.subnets_address)
      storage_account           = 1
      storage_container         = 1
      virtual_machine_scale_set = local.scale_sets
      public_ip                 = 1
      app_gateway               = 1
      key_vault                 = 1
      key_vault_certificate     = 1
      user_assigned_identity    = 1
      routing_rule              = local.scale_sets - 1
      http_listener             = local.scale_sets - 1
      frontend_ip_configuration = local.scale_sets - 1
      frontend_port             = local.scale_sets - 1
      backend_http_settings     = local.scale_sets - 1
      backend_address_pool      = local.scale_sets - 1
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.generated_names.domain.resource_group[0]
  location = var.location
  tags = {
    environment = var.environment
  }
}

resource "azurerm_user_assigned_identity" "user_identity" {
  name                = module.naming.generated_names.domain.user_assigned_identity[0]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_storage_account" "storage" {
  name                     = module.naming.generated_names.domain.storage_account[0]
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.storage_tier
  account_kind             = var.storage_kind
  account_replication_type = var.storage_replication_type
}

resource "azurerm_storage_container" "container" {
  name                  = module.naming.generated_names.domain.storage_container[0]
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_virtual_network" "vnet" {
  name                = module.naming.generated_names.domain.virtual_network[0]
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = [var.network_space]
  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  count                = length(local.subnets_address)
  name                 = module.naming.generated_names.domain.subnet[count.index]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.subnets_address[count.index]]
  service_endpoints    = ["Microsoft.KeyVault"]
}

module "app_gateway" {
  source                          = "./modules/app_gateway"
  resource_group                  = azurerm_resource_group.rg
  gateway_name                    = module.naming.generated_names.domain.app_gateway[0]
  private_ip                      = local.private_ip
  public_ip_name                  = module.naming.generated_names.domain.public_ip[0]
  subnet                          = azurerm_subnet.subnet[0]
  ssl_certificate                 = module.key_vault.ssl_certificate
  key_vault                       = module.key_vault.key_vault
  user_identity                   = azurerm_user_assigned_identity.user_identity
  allocation_method               = "Static"
  public_ip_sku                   = "Standard"
  domain_label                    = "highspot-poc"
  app_gateway_sku_name            = "WAF_v2"
  app_gateway_sku_tier            = "WAF_v2"
  app_gateway_capacity            = 2
  routing_rule_names              = module.naming.generated_names.domain.routing_rule
  http_listener_names             = module.naming.generated_names.domain.http_listener
  ports                           = local.ports
  port_names                      = module.naming.generated_names.domain.frontend_port
  frontend_ip_configuration_names = module.naming.generated_names.domain.frontend_ip_configuration
  backend_http_settings_names     = module.naming.generated_names.domain.backend_http_settings
  backend_address_pool_names      = module.naming.generated_names.domain.backend_address_pool
  depends_on                      = [module.key_vault.key_vault, module.key_vault.ssl_certificate]
  tags = {
    environment = var.environment
  }
}

module "scale_sets" {
  count                   = local.scale_sets
  source                  = "./modules/scale_set"
  resource_group          = azurerm_resource_group.rg
  vm_pass                 = random_password.password.result
  vmss_name               = module.naming.generated_names.domain.virtual_machine_scale_set[count.index]
  storage                 = (count.index < 2) ? azurerm_storage_account.storage : null
  subnet                  = azurerm_subnet.subnet[count.index + 1]
  backend_address_pool_id = [module.app_gateway.backend_address_pools[count.index]]
  tags = {
    environment = var.environment
  }
}

module "key_vault" {
  source               = "./modules/key_vault"
  resource_group       = azurerm_resource_group.rg
  kvault_name          = module.naming.generated_names.domain.key_vault[0]
  ssl_certificate_name = module.naming.generated_names.domain.key_vault_certificate[0]
  user_identity        = azurerm_user_assigned_identity.user_identity
  gateway_subnet_id    = azurerm_subnet.subnet[0].id
  secrets = [
    {
      name   = "vm-pass"
      secret = random_password.password.result
    },
    {
      name   = "private-ip"
      secret = local.private_ip
    }
  ]
}
