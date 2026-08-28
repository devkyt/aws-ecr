# ---------------------------------------------
# Repository Access Policy Built From User Input
# ---------------------------------------------
data "aws_iam_policy_document" "main" {
  dynamic "statement" {
    for_each = var.iam_policy

    content {
      sid     = statement.value.sid
      effect  = statement.value.effect
      actions = statement.value.actions

      resources = [aws_ecr_repository.main.arn]

      principals {
        type        = statement.value.principals.type
        identifiers = statement.value.principals.identifiers
      }

      dynamic "condition" {
        for_each = statement.value.conditions

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }

  lifecycle {
    enabled = local.create_ecr_policy
  }
}


# ---------------------------------------------
# Attach The Access Policy To The Repository
# ---------------------------------------------
resource "aws_ecr_repository_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = data.aws_iam_policy_document.main.json

  lifecycle {
    enabled = local.create_ecr_policy
  }
}
