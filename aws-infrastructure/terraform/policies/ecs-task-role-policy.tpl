${jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:GetAuthorizationToken",
        "CloudWatch:*",
        "kinesis:*",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "secretsmanager:GetSecretValue",
      "Effect": "Allow",
      "Resource": secrets_manager_resources
    },
    {
      "Action": "dynamodb:*",
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ssm:GetParametersByPath",
      "Resource": [
        "arn:aws:ssm:${region}:${account_id}:parameter/config/application*",
        "arn:aws:ssm:${region}:${account_id}:parameter/config/backend*"
      ]
    },
    <!-- Lab2: Add statement, which allow your application translate text using translate service -->
    <!-- Lab3: Add statement, which allow your application detect sentiment using comprehend service -->
    <!-- Lab1: Add statement, which allow your application to publish messages on all topics using sns service -->
  ]
}
)
}
