output "repository_name" {
  description = "The name of created ECR repository"
  value       = module.ecr.repository_name
}


output "repository_arn" {
  description = "The ARN of created ECR repository"
  value       = module.ecr.repository_arn
}


output "repository_url" {
  description = "The URL of created ECR repository"
  value       = module.ecr.repository_url
}
