# Our S3 buckets for this project.
#

# Largely created based on:
# terraform import aws_s3_bucket.ead  ead.sciencehistory.org


resource "aws_s3_bucket"  "ead" {
    provider = aws
    bucket = "ead.sciencehistory.org"

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

# terraform import aws_s3_bucket_ownership_controls.ead  ead.sciencehistory.org
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


# terraform import aws_s3_bucket_policy.ead  ead.sciencehistory.org

#resource "aws_s3_bucket_policy" "derivatives" {
#    bucket = aws_s3_bucket.derivatives.id
#    policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name: aws_s3_bucket.derivatives.id })
#}