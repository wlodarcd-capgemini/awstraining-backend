output "cluster_configuration" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --profile ${var.aws_profile_name}"
}
