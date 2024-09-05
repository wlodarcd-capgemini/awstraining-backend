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
    {
        "Effect": "Allow",
        "Action": "s3:PutObject",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "translate:TranslateText",
        "Resource": "*"
    },
    {
            "Effect": "Allow",
            "Action": "comprehend:DetectSentiment",
            "Resource": "*"
    }
  ]
}
)
}
