provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.tarraform_state.id
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    dynamodb_table = aws_dynamodb_table.basic-dynamodb-table.name
  }
}

resource "aws_s3_bucket" "tarraform_state" {
  bucket = "terraform_state_bucket"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.tarraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3-bucket-encryption" {
  bucket = aws_s3_bucket.tarraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.tarraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name         = "terraform-backend-state"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockId"

  attribute {
    name = "LockId"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}