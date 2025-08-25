terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-590183704678"
    key            = "terraform-infra.tfstate"
    region         = "us-east-1"
  }
}
