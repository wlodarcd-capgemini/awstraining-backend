output "hub" {
  value = "US"
}

output "account_id" {
  value = "467331071075"
}

output "availability_zones" {
  value = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c"
  ]
}

output "admin_user" {
  value = "cywinsky"
}

output "backend_service_deployment_desired_task_count" {
  description = "Desired Fargate tasks in cluster"
  value = 3
}