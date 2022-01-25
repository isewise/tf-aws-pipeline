terraform {
  backend "s3" {
    bucket = "terraform-cicd-project-638"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}