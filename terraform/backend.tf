terraform {
  backend "s3" {
    bucket = "bucket-devops-project-gp"
    key    = "devops-terraform.tfstate"
    region = "us-east-1"
  }
}