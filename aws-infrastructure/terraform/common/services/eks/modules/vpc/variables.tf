################################################################################
# General Variables from root module
################################################################################
variable "profile" {
  type    = string
}

variable "main-region" {
  type    = string
}

variable "azs" {
  type = list(string)
}