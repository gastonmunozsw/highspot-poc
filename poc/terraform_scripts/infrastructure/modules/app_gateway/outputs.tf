output "backend_address_pools" {
  description = "Backend address pool ids"
  value       = azurerm_application_gateway.app_gateway.backend_address_pool[*].id
}

output "gateway_frontend_ip" {
  description = "Public IP"
  value       = "http://${azurerm_public_ip.public_ip.ip_address}"
}
