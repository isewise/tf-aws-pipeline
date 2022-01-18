terraform {
  backend "s3" {
    bucket = "terraform-cicd-project-880"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}