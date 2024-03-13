provider "aws" {
  region = var.region
  shared_credentials_files = [ var.shared_credentials_file ]
  profile = var.profile
}

terraform {
  backend "s3" {
    dynamodb_table = "backend_tf_lock_remote_dynamo"
  }
}

data "terraform_remote_state" "globals" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "globals.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "security_groups" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "securitygroups.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ecs-prometheus-cluster" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key = "ecs-prometheus-cluster.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "sns" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key            = "sns.tfstate"
    region         = var.region
  }
}

module "ecs-prometheus-service" {
  source = "../../../modules/ecs-prometheus-service"
  service_name = "backend-prometheus"
  task_template_file = "../../../templates/backend-prometheus-task-definition.json.tpl"
  ecr_prometheus_url = data.terraform_remote_state.ecs-prometheus-cluster.outputs.ecr_prometheus_repository_url
  service_deployment_desired_task_count = data.terraform_remote_state.globals.outputs.backend_service_deployment_desired_task_count
  service_deployment_maximum_percent = 200
  service_deployment_minimum_healthy_percent = 50
  ecs_prometheus_cluster_id = data.terraform_remote_state.ecs-prometheus-cluster.outputs.cluster_id
  lb_target_group_arn = data.terraform_remote_state.ecs-prometheus-cluster.outputs.backend_ecs_lb_target_group_arn
  sg_prometheus_id = data.terraform_remote_state.ecs-prometheus-cluster.outputs.sg_prometheus_id
  subnets = data.terraform_remote_state.globals.outputs.main_subnet_ids
  profile = var.profile
  environment = var.environment
  region= var.region
  common_tags = var.common_tags
  alerts_priority_medium = data.terraform_remote_state.globals.outputs.cloudwatch_alerts_mapping_priority_medium
  sns_alarm_topic_arn = data.terraform_remote_state.sns.outputs.sns_alarm_cloudwatch_topic_arn
  prometheus_bucket_arn = data.terraform_remote_state.ecs-prometheus-cluster.outputs.prometheus_bucket_name
  discovery_filter = "application=backend"
}
