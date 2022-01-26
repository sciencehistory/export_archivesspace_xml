
Terraform configuration for (some) of the AWS infrastructure for this app.

## AWS Credentials
To work with Terraform configuration, you need to be using AWS credentials with sufficient access to create/modify/delete our resources. We generally use credentials associated with our personal accounts.

Terraform will find these credentials in your environment. Either ENV variables
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, OR your local [AWS credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where) by default in a profile called `admin`.

Or you can ask it to look in a different named profile with standard AWS_PROFILE env var, like `export AWS_PROFILE=other_profile_name`.

We recommend you keep these high-privilege AWS credentails in your credentials file in a profile called admin.

**NOTE**, if you have the AWS_* ENV varaibles set, they will always take precedence and be used!

**WARNING**, if you accidentally execute a terraform command without proper AWS credentials available, it may put your local terraform in a weird situation, where you need to re-run `terraform init` again after fixing credentials problems.  That should recover you and shouldn't result in any lasting problems though.

## Remote S3 Backend

This configuration is configured to use a Remote S3 backend for terraform, in the `backend.tf` file. It is using an AWS dynanodb table for locking, as recommended by terraform remote S3 backend. The actual resources used for the Remote S3 backend are configured in `shared_state_s3.tf`.

* https://www.terraform.io/docs/language/settings/backends/s3.html
* https://mohitgoyal.co/2020/09/30/upload-terraform-state-files-to-remote-backend-amazon-s3-and-azure-storage-account/
## Sensitive info
Do not put sensitive info into this repo.