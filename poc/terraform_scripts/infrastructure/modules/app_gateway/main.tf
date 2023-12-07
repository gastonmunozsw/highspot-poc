locals {
  backend_address_pool_name              = "backend_pool"
  listener_name                          = "listener"
  http_setting_name                      = "http_setting"
  frontend_ip_configuration_name         = "agip_config"
  frontend_port_name                     = "frontend_port"
}

resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  allocation_method   = var.allocation_method
  sku                 = var.public_ip_sku
  tags                = var.tags
}

resource "azurerm_application_gateway" "app_gateway" {
  name                = var.gateway_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  sku {
    name     = var.app_gateway_sku_name
    tier     = var.app_gateway_sku_tier
    capacity = var.app_gateway_capacity
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_version = "3.2"
  }

  gateway_ip_configuration {
    name      = "${var.gateway_name}_gateway_ip_configuration"
    subnet_id = var.subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  dynamic "frontend_port" {
    for_each = var.ports
    content {
      name = var.port_names[frontend_port.key]
      port = var.ports[frontend_port.key]
    }
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_names[1]
    subnet_id                     = var.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  dynamic "backend_address_pool" {
    for_each = var.ports
    content {
      name = var.backend_address_pool_names[backend_address_pool.key]
    }
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
  }

  dynamic "backend_http_settings" {
    for_each = var.ports
    content {
      name                  = var.backend_http_settings_names[backend_http_settings.key]
      cookie_based_affinity = "Disabled"
      port                  = var.ports[backend_http_settings.key]
      protocol              = "Http"
      request_timeout       = 60
    }
  }

  ssl_certificate {
    name     = var.domain_name
    data     = var.certificate.certificate_p12
    password = var.certificate.certificate_p12_password
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    host_name                      = var.domain_name
    ssl_certificate_name           = var.domain_name
  }

  dynamic "http_listener" {
    for_each = var.http_listener_names
    content {
      name = var.http_listener_names[http_listener.key]
      frontend_ip_configuration_name = var.frontend_ip_configuration_names[1]
      frontend_port_name             = var.port_names[http_listener.key]
      protocol                       = "Http"
    }
  }

  request_routing_rule {
    name                       = "public_routing_rule"
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 1
  }

  dynamic "request_routing_rule" {
    for_each = var.routing_rule_names
    content {
      name                       = var.routing_rule_names[request_routing_rule.key]
      rule_type                  = "Basic"
      http_listener_name         = var.http_listener_names[request_routing_rule.key]
      backend_address_pool_name  = var.backend_address_pool_names[request_routing_rule.key]
      backend_http_settings_name = var.backend_http_settings_names[request_routing_rule.key]
      priority                   = request_routing_rule.key + 10
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_identity.id]
  }

  tags = var.tags
}

resource "azurerm_dns_a_record" "example" {
  name                = "test"
  zone_name           = var.certificate_zone_name
  resource_group_name = var.resource_group.name
  ttl                 = 300
  records             = [azurerm_public_ip.public_ip.ip_address]
}
