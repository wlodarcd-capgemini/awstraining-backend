output "endpoint" {
  description = "URL to the Elasticsearch service"
  value = aws_elasticsearch_domain.elasticsearch_service_kibana.endpoint
}