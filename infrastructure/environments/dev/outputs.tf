output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.app.name
}

output "repository_url" {
  description = "Repository URL used for Docker image pushes."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster for the dev environment."
  value       = aws_ecs_cluster.app.name
}

output "app_log_group_name" {
  description = "CloudWatch log group name for the application."
  value       = aws_cloudwatch_log_group.app.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution IAM role."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task IAM role."
  value       = aws_iam_role.ecs_task.arn
}

output "image_repository_url" {
  description = "ECR repository URL for ECS task image references."
  value       = aws_ecr_repository.app.repository_url
}
