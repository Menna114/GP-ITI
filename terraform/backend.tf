# Root module - backend.tf

terraform {
  backend "s3" {
    bucket = "engy-bucket-project-gp"
    key    = "devops-terraform.tfstate"
    region = "us-east-1"
  }
}
