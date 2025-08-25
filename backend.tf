terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-211125418662"
    key            = "terraform-infra.tfstate"
    region         = "us-east-1"
  }
}
