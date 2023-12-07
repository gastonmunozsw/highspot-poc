
variable "environment" {
  description = "Enviroment"
  default     = "staging"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Valid values for var: environment are (dev, staging, prod)."
  }
}

variable "location" {
  description = "Location where resources will be deployed (Default westus2)"
  default     = "westus2"
}

variable "network_space" {
  description = "Network space CIDR (Default 10.21.0.0/26)"
  default     = "10.21.0.0/26"
  validation {
    condition     = can(cidrhost(var.network_space, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "storage_tier" {
  description = "Account storage tier"
  default     = "Standard"
}

variable "storage_kind" {
  description = "Account storage kind"
  default     = "StorageV2"
}

variable "storage_replication_type" {
  description = "Account storage replication type"
  default     = "LRS"
}