module "naming" {
  source       = "../modules/naming"
  product_area = "hsg"
  environment  = var.environment
  location     = var.location
  generator = {
    domain = {
      resource_group = 1
      image_gallery  = 1
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

resource "azurerm_shared_image_gallery" "image_gallery" {
  name                = module.naming.generated_names.domain.image_gallery[0]
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  description         = "Image versioning"

  tags = {
    environment = var.environment
  }
}
