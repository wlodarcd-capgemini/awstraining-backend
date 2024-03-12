output "hub" {
  value = "EMEA"
}

output "account_id" {
  value = "467331071075"
}

output "availability_zones" {
  value = [
    "eu-central-1a",
    "eu-central-1b",
    "eu-central-1c"
  ]
}

output "admin_user" {
  value = "cywinsky"
}

output "backend_service_deployment_desired_task_count" {
  description = "Desired Fargate tasks in cluster"
  value = 3
}