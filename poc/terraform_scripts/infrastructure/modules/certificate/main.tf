resource "azurerm_dns_zone" "dns" {
  name                = var.domain_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_txt_record" "dns_record" {
  name                = "_acme-challenge" 
  resource_group_name = var.resource_group_name
  zone_name           = azurerm_dns_zone.dns.name
  ttl                 = 3600
  record {
    value = "Acme challenge"
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "olneya@southworks.com"
}

resource "random_password" "cert" {
  length  = 24
  special = true
}

resource "acme_certificate" "cert" {
  account_key_pem          = acme_registration.reg.account_key_pem
  common_name              = var.domain_name
  certificate_p12_password = random_password.cert.result
#   depends_on               = [azurerm_dns_txt_record.dns_record]

  dns_challenge {
    provider = "azure"

    config = {
        AZURE_RESOURCE_GROUP  = azurerm_dns_zone.dns.resource_group_name
        AZURE_ZONE_NAME       = azurerm_dns_zone.dns.name
        AZURE_TTL             = 500
    }
  }
}
