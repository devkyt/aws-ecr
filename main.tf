# ---------------------------------------------
# ECR Container Image Repository
# ---------------------------------------------
resource "aws_ecr_repository" "main" {
  name                 = local.name
  image_tag_mutability = var.mutable ? "MUTABLE" : "IMMUTABLE"
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = true
  }

  dynamic "encryption_configuration" {
    for_each = var.kms_key_arn != null ? toset([1]) : toset([])

    content {
      encryption_type = "KMS"
      kms_key         = var.kms_key_arn
    }
  }

  tags = merge(local.tags,
    {
      Name = local.name
      Type = "ECR"
    }
  )
}


# ---------------------------------------------
# Default Image Retention Lifecycle Policy
# ---------------------------------------------
resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.main.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Delete untagged images older than ${var.untagged_retention_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_retention_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete tagged images older than ${var.retention_days} days"
        selection = {
          tagStatus      = "tagged"
          tagPatternList = ["*"]
          countType      = "sinceImagePushed"
          countUnit      = "days"
          countNumber    = var.retention_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3
        description  = "Always keep the last ${var.keep_always} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.keep_always
        }
        action = {
          type = "expire"
        }
      },
    ]
  })


  lifecycle {
    enabled = var.use_default_lifecycle_policy
  }
}


# ---------------------------------------------
# Custom User-Supplied Lifecycle Policy
# ---------------------------------------------
resource "aws_ecr_lifecycle_policy" "custom" {
  repository = aws_ecr_repository.main.name
  policy     = var.lifecycle_policy

  lifecycle {
    enabled = var.lifecycle_policy != null && !var.use_default_lifecycle_policy
  }
}
