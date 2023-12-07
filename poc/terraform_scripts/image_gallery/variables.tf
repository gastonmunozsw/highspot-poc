
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
