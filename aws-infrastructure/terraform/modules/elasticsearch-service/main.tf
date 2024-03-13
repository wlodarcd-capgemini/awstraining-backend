# Create the Elasticsearch domain
resource "aws_elasticsearch_domain" "elasticsearch_service_kibana" {
  domain_name           = "backend-domain"
  elasticsearch_version = "7.10"  # Update with your desired Elasticsearch version

  cluster_config {
    instance_type         = "t2.small.elasticsearch"  # Update with your desired instance type
    instance_count        = 1  # Update with the number of instances in the cluster
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10  # Update with your desired EBS volume size in GB
    volume_type = "gp2"  # Update with your desired EBS volume type
  }

  vpc_options {
    subnet_ids = [ var.subnets[0] ]
    security_group_ids = var.security_groups
  }

  tags = merge(
      var.common_tags,
      {
        Name: "Backend Elasticsearch Domain",
        Environment: var.environment
      }
    )
}

# Elasticsearch Lambda #
resource "aws_iam_role" "subscription_filter_lambda_role" {
  name = "backend-subscription-filter-lambda-role-${var.region}"
  assume_role_policy = file("../../../policies/lambda-assume-role-policy.json")
}

resource "aws_iam_policy" "subscription_filter_lambda_policy" {
  name = "backend-subscription-filter-lambda-role-policy-${var.region}"
  policy = file("../../../policies/lambda-write-to-elasticsearch.json")
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_attach" {
  role = aws_iam_role.subscription_filter_lambda_role.name
  policy_arn = aws_iam_policy.subscription_filter_lambda_policy.arn
}

data "archive_file" "elasticsearch_log_lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/src/index.js"
  output_path = "${path.module}/lambda/elasticsearch_log_lambda.zip"
}

resource "aws_lambda_function" "lambda_logs" {
  function_name = "LogsToElasticsearch_backend-domain"
  role          = aws_iam_role.subscription_filter_lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  filename         = "${path.module}/lambda/elasticsearch_log_lambda.zip"
  source_code_hash = data.archive_file.elasticsearch_log_lambda_zip.output_base64sha256
  timeout       = 300

  environment {
    variables = {
      myProject_elasticsearch_endpoint = aws_elasticsearch_domain.elasticsearch_service_kibana.endpoint
    }
  }
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id   = "InvokePermissionsForCloudWatchLog"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda_logs.function_name
  principal      = "logs.amazonaws.com"
  source_arn     = format("arn:aws:logs:%s:%s:log-group:%s:*", var.region, var.account_id, var.log_group_name)
  source_account = var.account_id
}

# Create a subscription filter for the log group
resource "aws_cloudwatch_log_subscription_filter" "fargate_log_group_to_elasticsearch" {
  name            = "EcsFargateLogsToElasticsearch"
  log_group_name  = var.log_group_name
  filter_pattern  = ""
  destination_arn = aws_lambda_function.lambda_logs.arn
}