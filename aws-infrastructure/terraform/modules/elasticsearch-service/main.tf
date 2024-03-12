# Create the Elasticsearch domain
resource "aws_elasticsearch_domain" "elasticsearch_service_kibana" {
  domain_name           = "backend-domain"
  elasticsearch_version = "7.10"  # Update with your desired Elasticsearch version
  instance_type         = "t2.small.elasticsearch"  # Update with your desired instance type
  instance_count        = 1  # Update with the number of instances in the cluster
  ebs_options {
    ebs_enabled = true
    volume_size = 10  # Update with your desired EBS volume size in GB
    volume_type = "gp2"  # Update with your desired EBS volume type
  }
  vpc_options {
    subnet_ids = var.subnets
    security_group_ids = var.security_groups
  }
}

# Create a subscription filter for the log group
resource "aws_cloudwatch_log_subscription_filter" "fargate_log_group_to_elasticsearch" {
  name            = "EcsFargateLogsToElasticsearch"
  log_group_name  = var.log_group_name
  filter_pattern  = ""
  destination_arn = aws_elasticsearch_domain.elasticsearch_service_kibana.arn
}