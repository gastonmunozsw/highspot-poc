variable "gateway_name" {
  description = "App Gateway Name"
}

variable "resource_group" {
  description = "Resource Group"
}

variable "private_ip" {
  description = "Private IP"
}

variable "public_ip_name" {
  description = "Public IP Name"
}

variable "subnet" {
  description = "Subnet"
}

variable "ssl_certificate" {
  description = "SSL Certificate"
}

variable "key_vault" {
  description = "Key Vault"
}

variable "user_identity" {
  description = "User Identity"
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = null
}

variable "allocation_method" {
  description = "Public IP allocation method"
}

variable "public_ip_sku" {
  description = "Public IP sku"
}

variable "domain_label" {
  description = "Public IP domain label"
}

variable "app_gateway_sku_name" {
  description = "Application gateway sku name"
}

variable "app_gateway_sku_tier" {
  description = "Application gateway sku tier"
}

variable "app_gateway_capacity" {
  description = "Application gateway sku capacity"
}

variable "ports" {
  type    = list(number)
}

variable "port_names" {
  type    = list(string)
}

variable "routing_rule_names" {
  type    = list(string)
}

variable "http_listener_names" {
  type    = list(string)
}

variable "frontend_ip_configuration_names" {
  type    = list(string)
}

variable "backend_http_settings_names" {
  type    = list(string)
}

variable "backend_address_pool_names" {
  type    = list(string)
}