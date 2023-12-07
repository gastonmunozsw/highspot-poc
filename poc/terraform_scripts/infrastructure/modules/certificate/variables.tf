variable "resource_group_name" {
  type        = string
  description = "The name of the resource group"
}

variable "location" {
  type        = string
  description = "The location to create the resources in"
}

variable "current" {
    description = "Current Azure user"
}

variable "domain_name" {
  description = "DNS Zone name"
}
