terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.5"
    }
  }
}

provider "acme" {
  # staging
#   server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
  # production
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}