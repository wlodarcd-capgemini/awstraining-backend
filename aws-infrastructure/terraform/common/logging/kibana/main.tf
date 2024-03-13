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

data "terraform_remote_state" "securitygroups" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "securitygroups.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "vpc.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "ecs_backend_service" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    dynamodb_table = "backend_tf_lock_remote_dynamo"
    key = "ecs-backend-service.tfstate"
    region = var.region
  }
}

module "elasticsearch_service" {
  source     = "../../../modules/elasticsearch-service"
  common_tags = var.common_tags
  log_group_name = "/ecs/backend"
  profile = var.profile
  region = var.region
  security_groups = [ data.terraform_remote_state.securitygroups.outputs.sg_backend_id ]
  subnets = data.terraform_remote_state.vpc.outputs.private_subnets_id
  environment = var.environment
  account_id = data.terraform_remote_state.globals.outputs.account_id
}