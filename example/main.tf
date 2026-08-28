locals {
  app    = "whatever"
  env    = "experiment"
  region = "eu-central-1"

  tags = {
    Name        = local.app
    Environment = local.env
    Region      = local.region
  }
}

terraform {
  backend "s3" {
    bucket = "terraform-experiments-state"
    region = "eu-central-1"
    key    = "whatever/terraform.tfstate"
  }
}


provider "aws" {
  region = local.region
}


module "ecr" {
  source = "git@github.com:devkyt/aws-ecr.git?ref=main&depth=1"

  app = local.app
  env = local.env

  # Optional: override repository name (defaults to app-env)
  # name = "my-custom-repo-name"

  # Image tag mutability (default: IMMUTABLE)
  mutable = false

  # Delete repository even if it contains images
  force_delete = false

  # Optional: KMS encryption (uses AES256 by default)
  # kms_key_arn = "arn:aws:kms:eu-central-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  # Lifecycle policy settings
  retention_days          = 90 # Delete tagged images after 90 days
  untagged_retention_days = 14 # Delete untagged images after 14 days
  keep_always             = 10 # Always keep at least 10 images

  # Optional: repository policy for cross-account access
  # iam_policy = [
  #   {
  #     sid = "AllowCrossAccountPull"
  #     principals = {
  #       type        = "AWS"
  #       identifiers = ["arn:aws:iam::123456789012:root"]
  #     }
  #     actions = [
  #       "ecr:GetDownloadUrlForLayer",
  #       "ecr:BatchGetImage",
  #     ]
  #   }
  # ]

  tags = local.tags
}
