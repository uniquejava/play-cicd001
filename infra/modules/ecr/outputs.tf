output "repository_urls" {
  description = "Map of repository names to their URLs"
  value       = { for repo in aws_ecr_repository.repos : repo.name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value       = { for repo in aws_ecr_repository.repos : repo.name => repo.arn }
}

output "repository_names" {
  description = "List of repository names"
  value       = [for repo in aws_ecr_repository.repos : repo.name]
}

output "registry_id" {
  description = "The registry ID where the repository was created"
  value       = data.aws_caller_identity.current.account_id
}

output "repository_registry_url" {
  description = "The URL of the registry"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}