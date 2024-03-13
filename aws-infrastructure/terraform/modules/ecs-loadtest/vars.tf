variable "task_template_file" {
  description = "Location of template file containing user data for launch config of EC2 instances for ECS cluster"
}

variable "name" {
  description = "resource name"
}

variable "region" {
  description = "Name of the region on which the service runs"
}

variable "sg_ecs_backend_id" {
  description = "Security group for FARGATE instances. Property needed for network mode 'awsvpc'"
}

variable "subnets" {
  description = "Subnets for auto scaling group where EC2 instances are spawned"
  type        = list
}

variable "ecr_backend_url" {
  description = "ECR Url backend"
}

variable "ecr_backend_image_tag" {
  description = "Name of the image tag of backend ECR"
}

variable "service_deployment_desired_task_count" {
  description = "Number of instances of task definition to keep running"
}

variable "ecs_backend_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "512"
}

variable "ecs_backend_fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "1024"
}

variable "environment" {}
variable "common_tags" {}
