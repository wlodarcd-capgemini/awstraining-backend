${jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:aws_region:aws_account_id:domain/domain_name/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "YOUR_IP_ADDRESS/32"  # Update with your IP address for access control
        }
      }
    }
  ]
}
}
)}