# Setup for the terraform shared state back-end being on S3, including
# a dynamodb table for locking.
#
#
# See: https://mohitgoyal.co/2020/09/30/upload-terraform-state-files-to-remote-backend-amazon-s3-and-azure-storage-account/
#

resource "aws_s3_bucket" "terraform_state" {
  bucket = "export-archivesspace-xml-terraform-state"

  tags                        = {
      "service" =  "ArchiveSpace"
      "use"     = "terraform"
  }
  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
	bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_locks" {
  name         = "export-archivesspace-xml-terraform-state-locks"


  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  tags                        = {
      "service" = "ArchiveSpace"
      "use"     = "terraform"
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}