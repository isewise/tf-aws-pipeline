resource "random_integer" "bucket_appendix" {
  min = 1
  max = 1000
}

variable "dockerhub_creds" {
  type = string
}

variable "codestar_creds" {
  type = string
}

variable "tf-version" {
  type        = string
  default     = "latest"
  description = "Pull the latest version of Terraform from DockerHub"
}

resource "random_integer" "bucket_appendix_2" {
  min = 1
  max = 1000
}