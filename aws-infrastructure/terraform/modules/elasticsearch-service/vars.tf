variable "region" {
  description = "Name of the region on which the service runs"
}

variable "profile" {
  description = "AWS profile name to use for the setup (e.g. ebc-e2e)"
}

variable "account_id" {
  description = "AWS account id"
}

variable "log_group_name" {
  description = "CloudWatch log group name for ECS Fargate"
}

variable "subnets" {
  description = "Subnets for Elasticsearch VPC domain"
  type        = list(string)
}

variable "security_groups" {
  description = "Security group IDs for Elasticsearch VPC domain"
  type        = list(string)
}

variable "common_tags" {}
