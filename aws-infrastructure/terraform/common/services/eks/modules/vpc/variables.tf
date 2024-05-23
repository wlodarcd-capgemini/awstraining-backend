################################################################################
# General Variables from root module
################################################################################
variable "profile" {
  type    = string
}

variable "region" {
  type    = string
}

variable "azs" {
  type = list(string)
}