variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "The region for the network"
  type        = string
}

variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "secret_ids" {
  description = "A map of secret IDs"
  type        = list(string)
}
