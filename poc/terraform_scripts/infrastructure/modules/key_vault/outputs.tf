output "ssl_certificate" {
  description = "SSL Certificate"
  value       = azurerm_key_vault_certificate.cert
}

output "key_vault" {
  description = "Key Vault"
  value       = azurerm_key_vault.vault
}
