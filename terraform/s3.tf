# Our S3 buckets for this project.
#

resource "aws_s3_bucket" "ead" {
  provider = aws
  bucket   = "ead.sciencehistory.org"
  # We do not want to specify an ACL for the bucket, as
  # Object Ownership is set to "Bucket owner enforced".
  # See https://github.com/hashicorp/terraform-provider-aws/issues/22069
  # See https://github.com/hashicorp/terraform-provider-aws/issues/22271 
  # Once this bug is solved, we can probably remove the acl line altogether.
  acl           = null
  force_destroy = false
  website {
    index_document = "index.html"
  }
  versioning {
    enabled    = false
    mfa_delete = false
  }
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    "service" = "ArchiveSspace"
    "use"     = "EAD files"
  }
  website_domain   = "s3-website-us-east-1.amazonaws.com"
  website_endpoint = "ead.sciencehistory.org.s3-website-us-east-1.amazonaws.com"
}

resource "aws_s3_bucket_ownership_controls" "ead" {
  bucket = aws_s3_bucket.ead.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "ead" {
  bucket = aws_s3_bucket.ead.id
  policy = templatefile("templates/s3_public_read_policy.tftpl", { bucket_name : aws_s3_bucket.ead.id })
}


# terraform import aws_iam_user.export_archivesspace_xml_user export_archivesspace_xml
resource "aws_iam_user" "export_archivesspace_xml_user" {
  force_destroy = false
  name          = "export_archivesspace_xml"
  tags = {
    "associated_heroku_site" = "https://dashboard.heroku.com/apps/export-archivesspace-xml"
    "associated_s3_bucket"   = "science-history-institute-archives-ead"
    "description"            = "This is used to export ArchivesSpace EADs to the s3 bucket."
  }
  tags_all = {
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


  tags = {
    "associated_project" = "export-archivesspace-xml"
    "description"        = "Allows user export_archivesspace_xml read - write - and list privileges on bucket science-history-institute-archives-ead ."
  }
  tags_all = {
    "associated_project" = "export-archivesspace-xml"
    "description"        = "Allows user export_archivesspace_xml read - write - and list privileges on bucket science-history-institute-archives-ead ."
  }
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:PutObjectTagging"
        ],
        "Resource" : [
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

resource "aws_cloudfront_distribution" "distribution" {
  aliases = [
    "ead.sciencehistory.org",
  ]
  comment             = "Serve our EADs over HTTPS"
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  tags                = {}
  tags_all            = {}

  wait_for_deployment = true
  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress               = true
    default_ttl            = 0
    max_ttl                = 0
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "ead.sciencehistory.org"
    trusted_key_groups     = []
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = "ead.sciencehistory.org.s3-website-us-east-1.amazonaws.com"
    origin_id           = "ead.sciencehistory.org"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "arn:aws:acm:us-east-1:335460257737:certificate/e648772f-2325-43c2-beda-cd1429d0d879"
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}