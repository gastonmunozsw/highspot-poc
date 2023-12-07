variable "resource_group" {
  description = "Resource group"
}

variable "vmss_name" {
  description = "Name for VMSS names"
}

variable "vm_pass" {
  description = "VM password"
}

variable "storage" {
  description = "Storage account"
  default     = null
}

variable "subnet" {
  description = "Subnet"
}

variable "backend_address_pool_id" {
  description = "Backend Address Pool Id"
  default     = null
}

variable "tags" {
  description = "Tags"
  type = map(string)
  default = null
}
