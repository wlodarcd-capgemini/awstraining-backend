data "template_file" "bucket_access" {
  template = file("${path.module}/../../policies/bucket-access-policy.json.tpl")

  vars = {
    bucket = aws_s3_bucket.prometheus_config_bucket.bucket
  }
}

resource "aws_iam_role" "ecs-prometheus-task-role" {
  name = "backend-prometheus-ecs-task-role-${var.region}"
  assume_role_policy = file(var.ecs_assume_role_policy_file)
}

resource "aws_iam_policy" "ecs-prometheus-task-role-policy" {
  name = "backend-prometheus-ecs-task-role-${var.region}"
  policy = file(var.ecs_task_prometheus_role_policy_file)
}

resource "aws_iam_role_policy_attachment" "ecs-prometheus-task-role-attach" {
  role = aws_iam_role.ecs-prometheus-task-role.name
  policy_arn = aws_iam_policy.ecs-prometheus-task-role-policy.arn
}

resource "aws_iam_policy" "bucket_access" {
  name = "iam_policy_backend_${var.environment}_${var.region}_prometheus_config_bucket_access"
  policy = data.template_file.bucket_access.rendered
}

resource "aws_iam_role_policy_attachment" "bucket_access" {
  policy_arn = aws_iam_policy.bucket_access.arn
  role = aws_iam_role.ecs-prometheus-task-role.name
}

data "template_file" "prometheus_config_template" {
  template = file("${path.module}/../../templates/prometheus.yml.tpl")

  vars = {
    hub = var.hub
    env = var.environment
    # get rid of https:// and /api from url
    alert_target_endpoint = regex("//(.*)/", var.alert_manager_api_gateway_url)[0]
  }
}

resource "aws_s3_bucket" "prometheus_config_bucket" {
  bucket = "aws-prometheus-backend-${var.environment}-${var.region}"
  acl = "private"
  versioning {
    enabled = true
  }

  lifecycle_rule {
    id = "delete"
    enabled = true

    noncurrent_version_expiration {
      days = 365
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(
    {
      "Name" = "aws-prometheus-${var.region}"
    }
  )
}

resource "aws_s3_bucket_policy" "require_SSL" {
  bucket = aws_s3_bucket.prometheus_config_bucket.id
  policy = templatefile("../../../policies/require-SSL-policy.tpl", {
    bucket_name = aws_s3_bucket.prometheus_config_bucket.id
  })
}

resource "aws_s3_bucket_object" "prometheus_config" {
  bucket = aws_s3_bucket.prometheus_config_bucket.id
  key = "prometheus/prometheus.yml"
  content = data.template_file.prometheus_config_template.rendered
  tags = var.common_tags
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.prometheus_config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_object" "spring_rules" {
  bucket = aws_s3_bucket.prometheus_config_bucket.id
  key = "prometheus/rules/spring-rules.yaml"
  content = file("${path.module}/rules/spring-rules.yaml")
  tags = var.common_tags
}

resource "aws_s3_bucket_object" "backend_rules" {
  bucket = aws_s3_bucket.prometheus_config_bucket.id
  key = "prometheus/rules/backend-rules.yaml"
  content = file("${path.module}/rules/backend-rules.yaml")
  tags = var.common_tags
}

resource "aws_security_group" "sg_prometheus" {
  description = "controls direct access to Prometheus application instances"
  vpc_id = var.vpc_id
  name = "sg_backend_prometheus"

  ingress {
    from_port = 9090
    to_port = 9090
    protocol = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = merge(
    {
      Terraform = "true"
      Environment = var.environment
      Name = "SG Prometheus"
    }
  )
}

resource "aws_lb" "prometheus-lb-internal" {
  name = "backend-prometheus-lb"
  internal = true
  load_balancer_type = "network"
  enable_deletion_protection = true

  subnets = var.subnet_ids
  tags = var.common_tags
}

resource "aws_lb_target_group" "prometheus-lb-target-group" {
  name = "backend-prometheus-tg"
  port = 9090
  protocol = "TCP"
  target_type = "ip"
  vpc_id = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/-/healthy"
    protocol            = "HTTP"
  }

  tags = var.common_tags

}

data "aws_acm_certificate" "prometheus-lb_certificate" {
  domain = var.prometheus_certificate_domain_name
  statuses = [
    "ISSUED"]
  most_recent = "true"
  tags = var.common_tags
}

resource "aws_lb_listener" "prometheus-ecs-lb-listener" {
  load_balancer_arn = aws_lb.prometheus-lb-internal.arn
  port = "9090"

  protocol = "TLS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = data.aws_acm_certificate.prometheus-lb_certificate.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.prometheus-lb-target-group.arn
  }

  tags = merge(
    var.common_tags
  )
}

resource "aws_ecs_cluster" "ecs-prometheus-cluster" {
  name = var.ecs_cluster_name
  capacity_providers = [
    "FARGATE_SPOT",
    "FARGATE"
  ]

  tags = var.common_tags
}

resource "aws_ecr_repository" "ecr-repository" {
  name = "backend-prometheus"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.common_tags,
    {
      "Name" = "backend-prometheus"
    }
  )
}

# adds Lifecycle policy to ecr repository, this allows the automation of cleaning up unused images
# - first rule deletes all untagged images that are older than 14 days
resource "aws_ecr_lifecycle_policy" "expire_images" {
  repository = aws_ecr_repository.ecr-repository.name
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire untagged images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "prometheus_certificate_expiring_10_days" {
  alarm_name = "backend-prometheus-certificate-expiring-in-10-days"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name = "DaysToExpiry"
  namespace = "AWS/CertificateManager"
  period = "86400"
  datapoints_to_alarm = "1"
  evaluation_periods = "1"
  statistic = "Minimum"
  threshold = "10"
  alarm_description = "Region=${var.region}; Priority=MAJOR; Env=${var.environment}; EventId=80701; Desc=Certificate for backend Prometheus in ${var.region} in ${var.environment} will expire in 10 days"
  alarm_actions = [
    var.sns_alarm_topic_arn]
  treat_missing_data = "breaching"
  dimensions = {
    CertificateArn = data.aws_acm_certificate.prometheus-lb_certificate.arn
  }
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "prometheus_certificate_expiring_30_days" {
  alarm_name = "backend-prometheus-certificate-expiring-in-30-days"
  comparison_operator = "LessThanOrEqualToThreshold"
  metric_name = "DaysToExpiry"
  namespace = "AWS/CertificateManager"
  period = "86400"
  datapoints_to_alarm = "1"
  evaluation_periods = "1"
  statistic = "Minimum"
  threshold = "30"
  alarm_description = "Region=${var.region}; Priority=MINOR; Env=${var.environment}; EventId=80702; Desc=Certificate for backend Prometheus in ${var.region} in ${var.environment} will expire in 30 days"
  alarm_actions = [
    var.sns_alarm_topic_arn]
  treat_missing_data = "breaching"
  dimensions = {
    CertificateArn = data.aws_acm_certificate.prometheus-lb_certificate.arn
  }
  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "prometheus_ecs_unhealthy_hosts" {
  alarm_name = "backend-prometheus-ecs-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  metric_name = "UnHealthyHostCount"
  namespace = "AWS/ApplicationELB"
  period = "60"
  datapoints_to_alarm = "10"
  evaluation_periods = "15"
  statistic = "Average"
  threshold = 1
  alarm_description = "Region=${var.region}; Priority=${var.alerts_priority_high}; Env=${var.environment}; EventId=80613; Desc=Unhealthy tasks in backend Prometheus reached threshold"
  alarm_actions = [
    var.sns_alarm_topic_arn]
  treat_missing_data = "missing"
  dimensions = {
    TargetGroup = aws_lb_target_group.prometheus-lb-target-group.arn_suffix
    LoadBalancer = aws_lb.prometheus-lb-internal.arn_suffix
  }
  tags = var.common_tags
}
