resource "null_resource" "next" {
  depends_on = [module.eks]
  provisioner "local-exec" {
    command     = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --profile ${var.aws_profile_name} --region ${var.region}"
    interpreter = ["PowerShell", "-Command"]
  }
}
