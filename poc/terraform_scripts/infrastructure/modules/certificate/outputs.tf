output "certificate" {
  value = acme_certificate.cert
}

output "certificate_zone_name" {
  value = azurerm_dns_zone.dns.name
}