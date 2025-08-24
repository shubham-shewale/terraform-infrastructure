provider "aws" {
  region = "us-east-1"
}

# Data resource to fetch caller identity (confirms authentication)
data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_user_arn" {
  value = data.aws_caller_identity.current.arn
}
