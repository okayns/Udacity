variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "{Get your own resource group name}"
}

variable "location" {
  description = "The location of the resources"
  type        = string
  default     = "East US"
}

variable "vm_count" {
  description = "Number of virtual machines to create"
  type        = number
  default     = 2
}
