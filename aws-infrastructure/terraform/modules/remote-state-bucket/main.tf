# Sets up an S3 bucket to store the remote states of all modules
resource "aws_s3_bucket" "remote_state" {
  bucket = var.remote_state_bucket
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

  tags = merge(
    var.common_tags,
    {
      "Name" = "remote_state_bucket"
    }
  )

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.remote_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
