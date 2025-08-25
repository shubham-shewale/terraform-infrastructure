terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-905418359995"
    key            = "terraform-infra.tfstate"
    region         = "us-east-1"
  }
}
