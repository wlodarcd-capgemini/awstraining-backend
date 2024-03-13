variable "region" {
  description = "Region to launch configuration in"
}

variable "remote_state_bucket" {
  description = "Remote state bucket for saving state"
}

variable "profile" {
  description = "Default profile id"
}

variable "shared_credentials_file" {
  description = "Path to cloud credentials"
}

variable "environment" {
  description = "Used to derive names of AWS resources. Use this to distinguish different environments for example"
}

variable "common_tags" {
  type = map(string)
}
