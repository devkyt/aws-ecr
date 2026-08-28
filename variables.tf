variable "name" {
  description = "Name for the image repo"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.name == null ? true : length(var.name) > 0
    error_message = "ECR repository name cannot be empty if provided."
  }

  validation {
    condition     = var.name == null ? true : can(regex("^[a-z0-9-/_]+$", var.name))
    error_message = "ECR repository name must contain only lowercase letters, numbers, hyphens, underscores, and forward slashes."
  }
}


variable "app" {
  description = "Application name"
  type        = string

  validation {
    condition     = length(var.app) > 0
    error_message = "Application name cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.app))
    error_message = "Application name must contain only lowercase letters, numbers, and hyphens."
  }
}


variable "env" {
  description = "Target environment"
  type        = string

  validation {
    condition     = length(var.env) > 0
    error_message = "Environment cannot be empty."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.env))
    error_message = "Environment must contain only lowercase letters, numbers, and hyphens."
  }
}


variable "mutable" {
  description = "Whether the repository is mutable"
  type        = bool
  default     = true
}


variable "force_delete" {
  description = "Delete repository even if it contains images"
  type        = bool
  default     = false
}


variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encryption"
  type        = string
  default     = null
  nullable    = true

  validation {
    condition = (
      var.kms_key_arn == null ||
      can(regex("^arn:aws:kms:[a-z0-9-]+:[0-9]{12}:key/[a-f0-9-]+$", var.kms_key_arn))
    )
    error_message = "KMS key ARN must be in a valid format: arn:aws:kms:region:account-id:key/key-id."
  }
}


variable "retention_days" {
  description = "How long to store tagged images before they will be deleted"
  type        = number
  default     = 90

  validation {
    condition     = var.retention_days > 0
    error_message = "Retention days must be greater than 0."
  }
}


variable "untagged_retention_days" {
  description = "How long to store untagged images before they will be deleted"
  type        = number
  default     = 14

  validation {
    condition     = var.untagged_retention_days > 0
    error_message = "Untagged retention days must be greater than 0."
  }
}


variable "keep_always" {
  description = "How many images to keep no matter what"
  type        = number
  default     = 10

  validation {
    condition     = var.keep_always >= 0
    error_message = "Keep always count must be non-negative."
  }
}


variable "use_default_lifecycle_policy" {
  description = "Use the default lifecycle policy that expires untagged and old images"
  type        = bool
  default     = true
}


variable "lifecycle_policy" {
  description = "Custom lifecycle policy JSON for the ECR repository. Cannot be used together with use_default_lifecycle_policy."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.lifecycle_policy == null || can(jsondecode(var.lifecycle_policy))
    error_message = "Lifecycle policy must be a valid JSON string."
  }
}


variable "iam_policy" {
  description = "IAM policy statements for the ECR repository policy. Resource is automatically set to the repository ARN."
  type = list(object({
    sid    = optional(string)
    effect = optional(string, "Allow")
    principals = object({
      type        = string
      identifiers = list(string)
    })
    actions = list(string)
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}


variable "use_name_prefix" {
  description = "Use name_prefix instead of a fixed name for the resources this module creates, so AWS appends a unique suffix"
  type        = bool
  default     = false
}


variable "include_default_tags" {
  description = "Whether or not to attach default tags specified in module"
  type        = bool
  default     = true
}


variable "tags" {
  description = "Tags to apply to ECR and the related resources"
  type        = map(string)
  default     = {}
}
