output "cluster_id" {
  value = aws_ecs_cluster.ecs-prometheus-cluster.id
}

output "prometheus_ecs_lb_target_group_arn" {
  value = aws_lb_target_group.prometheus-lb-target-group.arn
}

output "ecr_repository_url" {
  description = "The repo URL for ECR"
  value = aws_ecr_repository.ecr-repository.repository_url
}

output "prometheus_bucket_name" {
  description = "Bucket name"
  value = aws_s3_bucket.prometheus_config_bucket.bucket
}

output "sg_prometheus" {
  description = "Security group prometheus"
  value = aws_security_group.sg_prometheus.id
}

output "nlb_prometheus_arn" {
  description = "Network load balancer prometheus arn"
  value = aws_lb.prometheus-lb-internal.arn
}