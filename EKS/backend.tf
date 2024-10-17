terraform {
  backend "s3" {
    bucket = "terraform4jenkins0eks"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"
  }
}