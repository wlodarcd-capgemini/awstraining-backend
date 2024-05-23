################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../modules/vpc"

  region = var.region
  profile     = var.profile
  azs         = local.azs
}

################################################################################
# EKS Cluster Module
################################################################################

module "eks" {
  source = "../../modules/eks-cluster"

  region = var.region
  profile     = var.profile
  #rolearn     = var.rolearn

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

################################################################################
# AWS ALB Controller
################################################################################

module "aws_alb_controller" {
  source = "../../modules/aws-alb-controller"

  region  = var.region
  env_name     = var.env_name
  cluster_name = var.cluster_name

  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
}