resource "azurerm_key_vault" "vault" {
  name                       = var.kvault_name
  location                   = var.resource_group.location
  resource_group_name        = var.resource_group.name
  tenant_id                  = var.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  enable_rbac_authorization  = false

  access_policy {
    tenant_id = var.current.tenant_id
    object_id = var.current.object_id
    certificate_permissions = [
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "SetIssuers",
      "Update"
    ]

    key_permissions = [
      "Backup",
      "Create",
      "Decrypt",
      "Delete",
      "Encrypt",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Sign",
      "UnwrapKey",
      "Update",
      "Verify",
      "WrapKey"
    ]

    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Restore",
      "Restore",
      "Set"
    ]
  }

  access_policy {
    tenant_id = var.current.tenant_id
    object_id = var.user_identity.principal_id
    secret_permissions = [
      "Get"
    ]
  }
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each     = { for secret in var.secrets : secret.name => secret }
  name         = each.value.name
  value        = each.value.secret
  key_vault_id = azurerm_key_vault.vault.id
}
