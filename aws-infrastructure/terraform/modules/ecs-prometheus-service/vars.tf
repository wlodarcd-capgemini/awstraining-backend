# Variables for the ecs-vsn-deployment module
variable "service_name" {
  description = "Name of service to deploy"
}

variable "region" {
  description = "Name of the region on which the service runs"
}

variable "profile" {
  description = "AWS profile name to use for the setup (e.g. ebc-e2e)"
}

variable "ecs_prometheus_cluster_id" {
  description = "ECS cluster id generated when creating ECS cluster"
}

variable "service_deployment_desired_task_count" {
  description = "Number of instances of task definition to keep running"
}

variable "service_deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can run during a deployment (percentage of desired count)"
}

variable "service_deployment_minimum_healthy_percent" {
  description = "Minimum percentage of tasks that must be healthy during a deployment (percentage of desired count)"
}

variable "subnets" {
  type = list
  description = "Subnets for ECS instances to run. Property needed for network mode 'awsvpc'"
}

variable "sg_prometheus_id" {
  description = "Security group for ECS instances. Property needed for network mode 'awsvpc'"
}

variable "lb_target_group_arn" {
  description = "Target group for backend load balancer "
}

variable "alerts_priority_medium" {
  description = "Mapping priority for alert medium"
}

variable "sns_alarm_topic_arn" {
  description = "ARN of the SNS used for alarming by Cloudwatch and to which the Cloudwatch Alertmanager shall listen to"
  type = string
}

variable "task_template_file" {
  description = "Name of task template file for container configuration"
}

variable "ecr_prometheus_url" {
  description = "ECR Url Prometheus"
}

variable "prometheus_bucket_arn" {
  description = "Bucket ARN"
}

variable "discovery_filter" {
  description = "The filter to set for discovering ECS instances to scrape"
  type = string
}

variable "environment" {}

variable "common_tags" {}