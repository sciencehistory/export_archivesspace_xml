# configure our terraform backend to use shared state on S3, as
# configured in shared_state_s3.tf

# terraform {
#  backend "local" {
#    path = "terraform.tfstate"
#  }
# }

terraform {
  backend "s3" {
    profile = "admin"

    bucket = "export-archivesspace-xml-terraform-state"
    region = "us-east-1"
    key = "export-archivesspace-xml/terraform.tfstate"
    dynamodb_table = "export-archivesspace-xml-state-locks"
    encrypt = true
  }
}