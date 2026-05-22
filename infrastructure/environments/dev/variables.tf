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

variable "task_cpu" {
  description = "CPU units for the ECS Fargate task definition."
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Memory in MiB for the ECS Fargate task definition."
  type        = string
  default     = "512"
}

variable "image_tag" {
  description = "Image tag deployed by the ECS task definition."
  type        = string
  default     = "0.1.0"
}

variable "app_environment" {
  description = "Application environment value exposed to the container."
  type        = string
  default     = "dev"
}

variable "build_id" {
  description = "Build identifier exposed to the container."
  type        = string
  default     = "manual"
}

variable "build_date" {
  description = "Build date exposed to the container."
  type        = string
  default     = "unknown"
}
