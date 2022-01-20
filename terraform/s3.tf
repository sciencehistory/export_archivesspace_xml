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


# terraform import aws_iam_user.export_archivesspace_xml_user export_archivesspace_xml
resource "aws_iam_user" "export_archivesspace_xml_user" {
    force_destroy = false
    name = "export_archivesspace_xml"
    tags          = {
        "associated_heroku_site" = "https://dashboard.heroku.com/apps/export-archivesspace-xml"
        "associated_s3_bucket"   = "science-history-institute-archives-ead"
        "description"            = "This is used to export ArchivesSpace EADs to the s3 bucket."
    }
    tags_all          = {
        "associated_heroku_site" = "https://dashboard.heroku.com/apps/export-archivesspace-xml"
        "associated_s3_bucket"   = "science-history-institute-archives-ead"
        "description"            = "This is used to export ArchivesSpace EADs to the s3 bucket."
    }
}

#  arn:aws:iam::335460257737:policy/export_archivesspace_xml_policy 

#  aws_iam_policy.export_archivesspace_xml_policy

# terraform import aws_iam_policy.export_archivesspace_xml_policy arn:aws:iam::335460257737:policy/export_archivesspace_xml_policy 


resource "aws_iam_policy" "export_archivesspace_xml_policy" {
  name        = "export_archivesspace_xml_policy"
  path        = "/"
  description = "Eddie created this policy in January 2020. The policy allows IAM user export_archivesspace_xml to export EAD files from ArchivesSpace, via the API, to s3 bucket science-history-institute-archives-ead ." 


  tags        = {
          "associated_project" = "export-archivesspace-xml"
          "description"        = "Allows user export_archivesspace_xml read - write - and list privileges on bucket science-history-institute-archives-ead ."
  }
  tags_all    = {
            "associated_project" = "export-archivesspace-xml"
            "description"        = "Allows user export_archivesspace_xml read - write - and list privileges on bucket science-history-institute-archives-ead ."
    }
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectTagging"
            ],
            "Resource": [
                "arn:aws:s3:::ead.sciencehistory.org/*",
                "arn:aws:s3:::ead.sciencehistory.org"
            ]
        }
    ]
})
}

resource "aws_iam_user_policy_attachment" "export-archivesspace-xml_user_policy_attachment" {
   user       = aws_iam_user.export_archivesspace_xml_user.name
   policy_arn = aws_iam_policy.export_archivesspace_xml_policy.arn
}
