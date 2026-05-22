output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.app.name
}

output "repository_url" {
  description = "Repository URL used for Docker image pushes."
  value       = aws_ecr_repository.app.repository_url
}
