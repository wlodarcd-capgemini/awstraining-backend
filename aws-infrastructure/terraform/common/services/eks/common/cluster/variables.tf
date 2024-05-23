################################################################################
# Default Variables
################################################################################

variable "profile" {
  type    = string
}

variable "region" {
  type    = string
}


################################################################################
# EKS Cluster Variables
################################################################################
variable "cluster_name" {
  type    = string
  default = "training-eks-cluster"
}

#variable "rolearn" {
#  description = "Add admin role to the aws-auth configmap"
#}

################################################################################
# ALB Controller Variables
################################################################################

variable "env_name" {
  type    = string
  default = "dev"
}