data "template_file" "service_template" {
  template = file(var.task_template_file)

  vars = {
    name = "backend"
    image = "${var.ecr_backend_url}:${var.ecr_backend_image_tag}"
    log_group = var.name
    load_test_url = "https://api.backend.test.eu-central-1.aws.cloud.bmw"
    load_test_result_bucket_name = "backend-load-test-result-emea-test"
  }
}

data "aws_iam_role" "backend_ecs_role" {
  name = "backend-ecs-task-role-${var.region}"
}

data "aws_iam_role" "backend_ecs_execution_role" {
  name = "backend-ecs-execution-role-${var.region}"
}

# ECS Cluster for backend
resource "aws_ecs_cluster" "ecs_backend_cluster" {
  name = var.name
  capacity_providers = [
    "FARGATE_SPOT",
    "FARGATE"
  ]

  tags = merge(
    var.common_tags,
    {
      Name = "ecs-backend-loadtest-cluster"
    },
  )
}

resource "aws_ecs_service" "ecs_backend_service" {
  name            = var.name
  cluster         = aws_ecs_cluster.ecs_backend_cluster.id
  task_definition = aws_ecs_task_definition.ecs_backend_task.arn

  desired_count   = var.service_deployment_desired_task_count
  launch_type = "FARGATE"

  # configuration needed for awsvpc network mode for tasks
  network_configuration {
    subnets = var.subnets
    security_groups = [var.sg_ecs_backend_id]
    assign_public_ip = false
  }
  tags = var.common_tags
}

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "ecs_backend_log_group" {
  name              = "/ecs/${var.name}"
  retention_in_days = 30

  tags = merge(
    var.common_tags,
    {
      Name = "ecs-backend-loadtest-log-group"
    },
  )
}

# Task Definition
resource "aws_ecs_task_definition" "ecs_backend_task" {
  family = var.name
  container_definitions = data.template_file.service_template.rendered
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = data.aws_iam_role.backend_ecs_execution_role.arn
  task_role_arn = data.aws_iam_role.backend_ecs_role.arn
  cpu = var.ecs_backend_fargate_cpu
  memory = var.ecs_backend_fargate_memory

  tags = merge(
      var.common_tags,
      {
        Name = "ecs-backend-loadtest-task"
      },
  )
}



