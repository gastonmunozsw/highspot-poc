terraform {
  required_version = ">=1.2"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id = "b6c877b1-58ee-4c91-9c33-5caf62b9fec9"
  tenant_id = "b25036e3-de39-4fec-a4aa-bda41b870d38"
  subscription_id = "75ab23a0-d02b-42b6-9a4f-145937adfbcd"
  client_secret = "n2F8Q~S44vPErdJTCzQCjeCqE2M6D4L_~YbNNbgu"
}
