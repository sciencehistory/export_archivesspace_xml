# Our S3 buckets for this project.
#

resource "aws_s3_bucket"  "ead" {
    provider = aws
    bucket = "ead.sciencehistory.org"
    # We do not want to specify an ACL for the bucket, as
    # Object Ownership is set to "Bucket owner enforced".
    # See https://github.com/hashicorp/terraform-provider-aws/issues/22069
    # See https://github.com/hashicorp/terraform-provider-aws/issues/22271 
    # Once this bug is solved, we can probably remove the acl line altogether.
    acl                         = null
    force_destroy               = false
    website {
        index_document = "index.html"
    }
    versioning {
        enabled    = false
        mfa_delete = false
    }
    lifecycle {
      prevent_destroy           = true
    }
    tags                        = {
        "service" = "ArchiveSspace"
        "use"     = "EAD files"
    }
    website_domain = "s3-website-us-east-1.amazonaws.com"
    website_endpoint =  "ead.sciencehistory.org.s3-website-us-east-1.amazonaws.com"
}

resource "aws_s3_bucket_ownership_controls" "ead" {
  bucket = aws_s3_bucket.ead.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "ead" {
    bucket = aws_s3_bucket.ead.id
    policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name: aws_s3_bucket.ead.id })

}

