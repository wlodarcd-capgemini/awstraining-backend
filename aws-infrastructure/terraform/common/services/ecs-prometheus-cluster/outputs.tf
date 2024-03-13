output "cluster_id" {
  value = module.ecs-prometheus-cluster.cluster_id
}

output "backend_ecs_lb_target_group_arn" {
  value = module.ecs-prometheus-cluster.prometheus_ecs_lb_target_group_arn
}

output "ecr_prometheus_repository_url" {
  description = "The repo URL for Prometheus ECR"
  value = module.ecs-prometheus-cluster.ecr_repository_url
}

output "prometheus_bucket_name" {
  description = "Bucket name"
  value = module.ecs-prometheus-cluster.prometheus_bucket_name
}

output "sg_prometheus_id" {
  description = "Security group prometheus"
  value = module.ecs-prometheus-cluster.sg_prometheus
}

output "nlb_prometheus_arn" {
  description = "Network load balancer prometheus arn"
  value = module.ecs-prometheus-cluster.nlb_prometheus_arn
}