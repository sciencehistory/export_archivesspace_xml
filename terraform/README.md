Terraform configuration for (some) of the AWS infrastructure for Science History Institute Digital Collections app.

## AWS Credentials

To execute terraform configuration, you need to be using AWS credentials with sufficient access to create/modify/delete our resources. We generally use credentails associated with our personal accounts.

Terraform will find these credentails in your environment. Either ENV variables
`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, OR your local [AWS credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-where) by default in a profile called `admin`.

Or you can ask it to look in a different named profile with standard AWS_PROFILE env var, like `export AWS_PROFILE=other_profile_name`.

We recommend you keep these high-privilege AWS credentails in your credentials file in a profile called admin.

**NOTE**, if you have the AWS_* ENV varaibles set, they will always take precedence and be used!

**WARNING**, if you accidentally execute a terraform command without proper AWS credentials available, it may put your local terraform in a weird situation, where you need to re-run `terraform init` again after fixing credentials problems.  That should recover you and shouldn't result in any lasting problems though.

## We use workspace for production/staging tiers

We use the terraform _workspaces_ feature to join/separate staging and production. When we asked around, our library peers using terraform seemed to use this technique. While terraform docs/community are split on whether it's appropriate, couldn't find a better way to do it for our needs.
This setup does lead to some workarounds where things diverge between production and staging (such as replication rules for backup buckets).

This means you need to select `staging` or `production` workspaces before running terraform commands:

```
terraform workspace select staging
# or
terraform workspace select production

# see also:
terraform workspace list
terraform workspace show
```

Don't use the default workspace, we don't use that.

After selecting your workspace, you might want to run the standard commands `terraform plan` or `terraform apply`. BE CAREFUL what workspace you are in, production or staging!

## Outputs

Outputs in all caps may likely match heroku config vars that should be set to values. Initially `RAILS_ASSET_HOST` wtih cloudfront host. Run `terraform output`, or look for outputs after a `terraform apply`.

## Desired change workflow, git

It's a bit confusing, but the idea is that for _production_ we *only* run `terraform apply` off of `main` branch, with all changes committed and pushed to github.

In staging, you can run `terraform apply` off of a non-main branch. If all looks good, merge to main, then run on production off of main branch.

While there's currently nothing to stop you, we really don't want to run production `terraform apply` off of changes that aren't both committed and pushed to github; or off of non-main branches.

## Remote S3 Backend

This configuration is configured to use a Remote S3 backend for terraform, in the `backend.tf` file. It is using an AWS dynanodb table for locking, as recommended by terraform remote S3 backend. The actual resources used for the Remote S3 backend are configured in `shared_state_s3.tf`.

* https://www.terraform.io/docs/language/settings/backends/s3.html
* https://mohitgoyal.co/2020/09/30/upload-terraform-state-files-to-remote-backend-amazon-s3-and-azure-storage-account/


## Sensitive info

**Do not put sensitive info in this repository**. Such as credentials etc.

At this writing, our terraform may not actually be managing an sensitive info. If we have that need, we may need to do more research/study to understand the most convenient and secure way to do it. Under no case should they be in the repo in plaintext though.

## Limitations, resources not controlled by terraform

To begin with, we are only configuring a limited subset of AWS resources in terraform: S3 and Cloudfront.

This means we have some resources in AWS that are not configured here, but only set up manually.

* IAM (users, groups, roles, policies) -- quite a bit. This would a good idea to get in terraform, but also kind of complicated.
* SES (SMTP email)

Also we *could* (but don't) have non-AWS resources not controlled here. Some things (like most but not all of our heroku config) *could* be controlled via terraform. Other things (like SearchStax), probably not.

if adding more resources, we might want to separate into multiple terraform configurations, instead of just having one big one. That seems to be the current terraform advice.
