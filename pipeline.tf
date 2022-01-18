resource "aws_codebuild_project" "tf-plan" {
  name         = "tf-cicd-plan"
  description  = "TF plan stage"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:${var.tf-version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_creds
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/plan-buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf-apply" {
  name         = "tf-cicd-apply"
  description  = "TF apply stage"
  service_role = aws_iam_role.tf-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:${var.tf-version}"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential {
      credential          = var.dockerhub_creds
      credential_provider = "SECRETS_MANAGER"
    }
  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("buildspec/apply-buildspec.yml")
  }
}

resource "aws_codepipeline" "tf-pipeline" {
  name     = "tf-pipeline"
  role_arn = aws_iam_role.tf-codebuild-role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.id
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      output_artifacts = ["tf-code"]
      version          = "1"
      configuration = {
        FullRepositoryId     = "isewise/tf-aws-pipeline"
        BranchName           = "master"
        ConnectionArn        = var.codestar_creds
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }
  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "tf-cicd-plan"
      }
    }
  }
  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["tf-code"]
      configuration = {
        ProjectName = "tf-cicd-apply"
      }
    }
  }
}