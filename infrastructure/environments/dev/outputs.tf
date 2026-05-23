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

output "default_vpc_id" {
  description = "ID of the default VPC used for the first ECS service version."
  value       = data.aws_vpc.default.id
}

output "default_subnet_ids" {
  description = "Subnet IDs from the default VPC."
  value       = data.aws_subnets.default.ids
}

output "alb_security_group_id" {
  description = "Security group ID for the future application load balancer."
  value       = aws_security_group.alb.id
}

output "ecs_task_security_group_id" {
  description = "Security group ID for ECS Fargate tasks."
  value       = aws_security_group.ecs_task.id
}

output "alb_dns_name" {
  description = "DNS name of the application load balancer."
  value       = aws_lb.app.dns_name
}

output "alb_arn" {
  description = "ARN of the application load balancer."
  value       = aws_lb.app.arn
}

output "alb_target_group_arn" {
  description = "ARN of the ALB target group for ECS tasks."
  value       = aws_lb_target_group.app.arn
}

output "alb_listener_arn" {
  description = "ARN of the HTTP listener for the application load balancer."
  value       = aws_lb_listener.http.arn
}

output "task_definition_family" {
  description = "Family name of the ECS task definition."
  value       = aws_ecs_task_definition.app.family
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.app.arn
}

output "ecs_service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.app.name
}

output "ecs_service_id" {
  description = "ID of the ECS service."
  value       = aws_ecs_service.app.id
}
