data "aws_caller_identity" "current" {}

# Bucket for build artifacts / reports. The account ID keeps the name globally unique.
resource "aws_s3_bucket" "assets" {
  bucket        = "${var.project}-assets-${data.aws_caller_identity.current.account_id}"
  force_destroy = true

  tags = { Name = "${var.project}-assets" }
}

resource "aws_s3_bucket_versioning" "assets" {
  bucket = aws_s3_bucket.assets.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "architecture" {
  bucket       = aws_s3_bucket.assets.id
  key          = "architecture.txt"
  content      = "VPC ${aws_vpc.main.cidr_block} -> subnet ${aws_subnet.public.cidr_block} -> EC2 ${aws_instance.web.id}\n"
  content_type = "text/plain"
}
