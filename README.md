# AWS ECR

OpenTofu module for Elastic Container Registry provisioning. You can find how to use it in [example](./example/) folder
and in the [Examples](#examples) section below.

## Table of Contents

- [Requirements](#requirements)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)
  - [Basic Repository](#basic-repository)
  - [Cross-Account Access](#cross-account-access)
  - [Custom Lifecycle Policy](#custom-lifecycle-policy)
  - [KMS Encryption](#kms-encryption)

## Requirements

| Name | Version |
|------|---------|
| OpenTofu | >= 1.11 |
| AWS provider | ~> 6.0  |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name for the image repo. Defaults to {app}-{env} | `string` | `null` | no |
| `app` | Application name | `string` | - | yes |
| `env` | Target environment | `string` | - | yes |
| `mutable` | Whether the repository is mutable | `bool` | `true` | no |
| `force_delete` | Delete repository even if it contains images | `bool` | `false` | no |
| `kms_key_arn` | ARN of the KMS key to use for encryption | `string` | `null` | no |
| `retention_days` | How long to store tagged images before they will be deleted | `number` | `90` | no |
| `untagged_retention_days` | How long to store untagged images before they will be deleted | `number` | `14` | no |
| `keep_always` | How many images to keep no matter what | `number` | `10` | no |
| `use_default_lifecycle_policy` | Use the default lifecycle policy that expires untagged and old images | `bool` | `true` | no |
| `lifecycle_policy` | Custom lifecycle policy JSON. Requires use_default_lifecycle_policy to be false | `string` | `null` | no |
| `iam_policy` | IAM policy statements for the ECR repository policy. Resource is automatically set to the repository ARN | `list(object)` | `[]` | no |
| `use_name_prefix` | Use name_prefix instead of a fixed name for created resources, so AWS appends a unique suffix | `bool` | `false` | no |
| `include_default_tags` | Whether or not to attach default tags specified in module | `bool` | `true` | no |
| `tags` | Tags to apply to ECR and the related resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `repository_name` | The name of created ECR repository |
| `repository_arn` | The ARN of created ECR repository |
| `repository_url` | The URL of created ECR repository |
| `registry_id` | The registry ID where the repository was created |

## Examples

### Basic Repository

A minimal ECR repository with immutable tags and default lifecycle policies.

```hcl
module "ecr" {
  source = "git@github.com:devkyt/aws-ecr.git?ref=main&depth=1"

  app = "whatever"
  env = "experiment"

  mutable = false
}
```

### Cross-Account Access

Granting another AWS account pull access to the repository.

```hcl
module "ecr" {
  source = "git@github.com:devkyt/aws-ecr.git?ref=main&depth=1"

  app = "whatever"
  env = "experiment"

  iam_policy = [
    {
      sid = "AllowCrossAccountPull"
      principals = {
        type        = "AWS"
        identifiers = ["arn:aws:iam::123456789012:root"]
      }
      actions = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
      ]
    }
  ]
}
```

### Custom Lifecycle Policy

Using a custom lifecycle policy instead of the built-in defaults.

```hcl
module "ecr" {
  source = "git@github.com:devkyt/aws-ecr.git?ref=main&depth=1"

  app = "whatever"
  env = "experiment"

  use_default_lifecycle_policy = false

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
```

### KMS Encryption

Using a custom KMS key for repository encryption.

```hcl
module "ecr" {
  source = "git@github.com:devkyt/aws-ecr.git?ref=main&depth=1"

  app = "whatever"
  env = "experiment"

  kms_key_arn = "arn:aws:kms:eu-central-1:123456789012:key/a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

## License

Licensed under the Apache License, Version 2.0.

Copyright 2026 Kyrylo Tykhanskyi.
