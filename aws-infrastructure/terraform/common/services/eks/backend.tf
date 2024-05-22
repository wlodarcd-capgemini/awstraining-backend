terraform {
  backend "s3" {
    bucket = var.state_bucket
    key    = "eks"
    region = var.region
    profile = var.aws_profile_name
  }
}