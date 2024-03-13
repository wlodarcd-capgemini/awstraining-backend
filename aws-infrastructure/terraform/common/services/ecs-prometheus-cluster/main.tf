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

data "terraform_remote_state" "sns" {
  backend = "s3"
  config = {
    bucket         = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key            = "sns.tfstate"
    region         = var.region
  }
}

data "terraform_remote_state" "prometheus-alertmanager" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "prometheus-alertmanager.tfstate"
    region = var.region
  }
}

module "ecs-prometheus-cluster" {
  source = "../../../modules/ecs-prometheus-cluster"
  ecs_cluster_name = "backend-prometheus-ecs-${var.environment}"
  vpc_id = data.terraform_remote_state.globals.outputs.vpc_id
  environment = var.environment
  common_tags = var.common_tags
  subnets = data.terraform_remote_state.globals.outputs.main_subnet_ids
  region = var.region
  backend_service_deployment_desired_task_count = data.terraform_remote_state.globals.outputs.prometheus_service_deployment_desired_task_count
  alerts_priority_high = data.terraform_remote_state.globals.outputs.cloudwatch_alerts_mapping_priority_high
  sns_alarm_topic_arn = data.terraform_remote_state.sns.outputs.sns_alarm_cloudwatch_topic_arn
  allowed_cidr_blocks = concat(
    data.terraform_remote_state.globals.outputs.jenkins_slaves,
    [data.terraform_remote_state.globals.outputs.vpc_cidr],
    ["0.0.0.0/0"])
  prometheus_certificate_domain_name = data.terraform_remote_state.globals.outputs.prometheus_certificate_domain_name
  subnet_ids = data.terraform_remote_state.globals.outputs.main_subnet_ids
  alert_manager_api_gateway_url = data.terraform_remote_state.prometheus-alertmanager.outputs.alert_manager_endpoint
  hub = data.terraform_remote_state.globals.outputs.hub
  ecs_assume_role_policy_file = data.terraform_remote_state.globals.outputs.ecs_assume_role_policy_file
  ecs_task_prometheus_role_policy_file = data.terraform_remote_state.globals.outputs.ecs_task_prometheus_role_policy_file
}
