provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "terraform-cicd-project-${random_integer.bucket_appendix.id}"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "cicd-pipeline-artifacts-${random_integer.bucket_appendix_2.id}"
  acl    = "private"
}