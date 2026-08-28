locals {
  name = coalesce(var.name, "${var.app}-${var.env}")

  create_ecr_policy = length(var.iam_policy) > 0

  default_tags = var.include_default_tags ? {
    App         = var.app
    Environment = var.env
    Env         = var.env
    Terraform   = "true"
    ManagedBy   = "Terraform"
  } : {}

  tags = merge(local.default_tags, var.tags)
}
