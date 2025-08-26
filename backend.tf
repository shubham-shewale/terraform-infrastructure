terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-058264474160"
    key            = "terraform-infra.tfstate"
    region         = "us-east-1"
  }
}
