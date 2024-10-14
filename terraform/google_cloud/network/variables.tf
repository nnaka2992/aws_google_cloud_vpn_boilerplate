variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "project_id" {
  description = "The ID of the project."
  type        = string
}

variable "region" {
  description = "The region in which the resources will be created."
  type        = string
}

# variable "cidr_block" {
#   description = "The CIDR block for the VPC. The CIDR block must be between a /16 netmask and /20 netmask."
#   type        = string
# }
