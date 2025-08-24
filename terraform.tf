terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-730335448602"
    key            = "terraform-infra/"
    region         = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}