locals {
  has_storage_access = (var.storage != null) ? 1 : 0
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                            = var.vmss_name
  resource_group_name             = var.resource_group.name
  location                        = var.resource_group.location
  sku                             = "Standard_D2ps_v5"
  instances                       = 2
  admin_username                  = "azureuser"
  admin_password                  = var.vm_pass
  disable_password_authentication = false
  upgrade_mode                    = "Automatic"
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-arm64"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "${var.subnet.name}_network_interface"
    primary = true

    ip_configuration {
      name                                         = "internal"
      primary                                      = true
      subnet_id                                    = var.subnet.id
      application_gateway_backend_address_pool_ids = var.backend_address_pool_id
    }
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "role_assignment" {
  count                = local.has_storage_access
  scope                = var.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
}
