variable "environment" {
  type        = string
  description = "A environment tag that will be added to the resources."
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for the subnets"
}

variable "common_tags" {}