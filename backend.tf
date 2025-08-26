terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-381492080129"
    key            = "terraform-infra.tfstate"
    region         = "us-east-1"
  }
}
