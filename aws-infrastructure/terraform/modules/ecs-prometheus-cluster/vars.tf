variable "ecs_cluster_name" {
  description = "ECS cluster name"
}

variable "vpc_id" {
  description = "ID of the VPC in which the Prometheus should be created in "
  type = string
}

variable "desired_capacity" {
  description = "Desired size of the auto scaling group"
  default     = 2
}

variable "max_size" {
  description = "Maximum size of the auto scaling group"
  default     = 3
}

variable "min_size" {
  description = "Minimal size of the auto scaling group"
  default     = 2
}

variable "subnets" {
  description = "Subnets for auto scaling group where EC2 instances are spawned"
  type        = list
}

variable "backend_service_deployment_desired_task_count" {
  description = "Desired count of running backend tasks"
}

variable "hub" {
  description = "The Hub in which the Prometheus instance runs in"
  type = string
}

variable "alert_manager_api_gateway_url" {
  description = "Pass from outputs from prometheus-alertmanager"
  type = string
}

variable "alerts_priority_high" {
  description = "Mapping priority for alert high"
}

variable "sns_alarm_topic_arn" {
  description = "ARN of the SNS used for alarming by Cloudwatch and to which the Cloudwatch Alertmanager shall listen to"
  type = string
}

variable "allowed_cidr_blocks" {
  description = "All CIDR Blocks that are allowed to access the Prometheus on its port 9090"
  type = list(string)
}

variable "subnet_ids" {
  description = "Subnet IDs in which to create Prometheus"
  type = list(string)
}

variable "prometheus_certificate_domain_name" {
  description = "Certificate for Prometheus"
}

variable "secrets_manager_resources" {
  description = "Arns of needed resources."
  type = list(string)
  default = []
}

variable "ecs_task_prometheus_role_policy_file" {
  description = "File for ecs_task_role_policy"
  type = string
}

variable "ecs_assume_role_policy_file" {
  description = "File for ecs_assume_role_policy"
  type = string
}

variable "environment" {}
variable "region" {}


variable "common_tags" {}