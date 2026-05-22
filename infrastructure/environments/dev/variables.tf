variable "aws_region" {
  description = "AWS region for the dev environment."
  type        = string
  default     = "eu-west-2"
}

variable "repository_name" {
  description = "Name of the ECR repository for the application image."
  type        = string
  default     = "ecs-fargate-readiness-lab"
}

variable "project_name" {
  description = "Base name used for ECS foundation resources in the dev environment."
  type        = string
  default     = "ecs-fargate-readiness-lab"
}
