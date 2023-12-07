variable "resource_group" {
  description = "Resource group"
}

variable "kvault_name" {
  description = "Key Vault Name"
}

variable "secrets" {
  description = "Secrets to store in the Key Vault"
  type = list(object({
    name   = string
    secret = string
  }))
}

variable "user_identity" {
  description = "User Identity"
}

variable "gateway_subnet_id" {
  description = "Gateway Subnet Id"
}

variable "current" {
    description = "Current Azure user"
}