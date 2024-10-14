variable "project_name" {
  description = "The project name"
  type        = string
}

variable "vpn_conn" {
  description = "VPN connection details"
  type = map(object({
    tunnel1_inside_cidr = string
    tunnel2_inside_cidr = string
  }))
}

variable "preshared_key_secret_id" {
  description = "The secret id for the preshared key"
  type        = string
}

################################################################################
# AWS's parameters
################################################################################
variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
}

variable "aws_vpc" {
  description = "The AWS VPC to connect to the VPN gateway"
  type = map(object({
    vpc_id        = string
    subnet_ids    = list(string)
    ip_cidr_range = set(string)
  }))
}

variable "aws_bgp_asn" {
  description = "The BGP ASN for the VPN gateway"
  type        = number
  validation {
    condition     = var.aws_bgp_asn >= 1 && var.aws_bgp_asn <= 4294967294
    error_message = "BGP ASN must be in range between 1 and 4294967294."
  }
}


################################################################################
# Google Cloud's parameters
################################################################################
variable "google_project_id" {
  description = "The project id"
  type        = string
}

variable "google_region" {
  description = "The Google Cloud's region to create resources in"
  type        = string
}

variable "google_vpc_id" {
  description = "The Google Cloud's VPC to connect to the VPN gateway"
  type        = string
}

variable "google_bgp_asn" {
  description = "The Google Cloud side bgp ASN"
  type        = number
  validation {
    condition     = var.google_bgp_asn >= 64512 && var.google_bgp_asn <= 65534 || var.google_bgp_asn >= 4200000000 && var.google_bgp_asn <= 4294967294
    error_message = "BGP ASN must be in range between 64512 and 65534 or 4200000000 and 4294967294."
  }
}
