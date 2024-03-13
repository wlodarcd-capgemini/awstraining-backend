data "template_file" "service_template" {
  template = file(var.task_template_file)
  vars = {
    image = "${var.ecr_prometheus_url}:latest"
    environment = var.environment
    region = var.region
    log_group = var.service_name
    config_bucket = var.prometheus_bucket_arn
    discovery_filter = var.discovery_filter
  }
}

data "aws_iam_role" "backend_ecs_role" {
  name = "backend-ecs-task-role-${var.region}"
}

data "aws_iam_role" "backend_prometheus_ecs_role" {
  name = "backend-prometheus-ecs-task-role-${var.region}"
}

resource "aws_ecs_task_definition" "ecs_prometheus_task" {
  family = var.service_name
  container_definitions = data.template_file.service_template.rendered
  network_mode = "awsvpc"
  execution_role_arn = data.aws_iam_role.backend_ecs_role.arn
  task_role_arn = data.aws_iam_role.backend_prometheus_ecs_role.arn
  requires_compatibilities = ["FARGATE"]
  memory = "512"
  cpu = "256"

  tags = var.common_tags
}

resource "aws_ecs_service" "ecs_prometheus_service" {
  name = var.service_name
  cluster = var.ecs_prometheus_cluster_id
  task_definition = aws_ecs_task_definition.ecs_prometheus_task.arn
  desired_count = var.service_deployment_desired_task_count
  health_check_grace_period_seconds = 30
  deployment_maximum_percent = var.service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.service_deployment_minimum_healthy_percent
  launch_type = "FARGATE"

  # configuration needed for awsvpc network mode for tasks
  network_configuration {
    subnets = var.subnets
    security_groups = [
      var.sg_prometheus_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name = "backend-prometheus"
    container_port = 9090
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "ecs_prometheus_log_group" {
  name = "/ecs/${var.service_name}"
  retention_in_days = 30
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "prometheus_cpu_utilization" {
  alarm_name = "backend-prometheus-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name = "CPUUtilization"
  namespace = "AWS/ECS"
  period = "60"
  datapoints_to_alarm = "2"
  evaluation_periods = "2"
  statistic = "Average"
  threshold = "80"
  alarm_description = "Region=${var.region}; Env=${var.environment}; Desc=The CPU utilization of backend Prometheus is above 80%"
  alarm_actions = [
    var.sns_alarm_topic_arn]
  treat_missing_data = "missing"
  dimensions = {
    ClusterName = "backend-prometheus-ecs-${var.environment}"
    ServiceName = aws_ecs_service.ecs_prometheus_service.name
  }
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "prometheus_memory_utilization" {
  alarm_name = "backend-prometheus-memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  metric_name = "MemoryUtilization"
  namespace = "AWS/ECS"
  period = "60"
  datapoints_to_alarm = "2"
  evaluation_periods = "2"
  statistic = "Average"
  threshold = "95"
  alarm_description = "Region=${var.region}; Env=${var.environment}; Desc=The memory utilization of backend Prometheus is above 95%"
  alarm_actions = [
    var.sns_alarm_topic_arn]
  treat_missing_data = "missing"
  dimensions = {
    ClusterName = "backend-prometheus-ecs-${var.environment}"
    ServiceName = aws_ecs_service.ecs_prometheus_service.name
  }
  tags = var.common_tags
}