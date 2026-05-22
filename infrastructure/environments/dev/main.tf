terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  ecs_cluster_name             = "${var.project_name}-dev"
  app_log_group_name           = "/ecs/${var.project_name}"
  ecs_task_execution_role_name = "${var.project_name}-task-execution-role"
  ecs_task_role_name           = "${var.project_name}-task-role"
  ecs_task_definition_family   = "${var.project_name}-app"
  app_container_name           = "${var.project_name}-app"
  alb_security_group_name      = "${var.project_name}-alb-sg"
  ecs_task_security_group_name = "${var.project_name}-task-sg"
}

resource "aws_ecr_repository" "app" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_ecs_cluster" "app" {
  name = local.ecs_cluster_name
}

resource "aws_cloudwatch_log_group" "app" {
  name              = local.app_log_group_name
  retention_in_days = 30
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = local.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task" {
  name               = local.ecs_task_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_security_group" "alb" {
  name        = local.alb_security_group_name
  description = "Security group for the future application load balancer."
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group" "ecs_task" {
  name        = local.ecs_task_security_group_name
  description = "Security group for ECS Fargate tasks."
  vpc_id      = data.aws_vpc.default.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_internet" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_all_outbound" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "ecs_task_from_alb" {
  security_group_id            = aws_security_group.ecs_task.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 8000
  ip_protocol                  = "tcp"
  to_port                      = 8000
}

resource "aws_vpc_security_group_egress_rule" "ecs_task_all_outbound" {
  security_group_id = aws_security_group.ecs_task.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_ecs_task_definition" "app" {
  family                   = local.ecs_task_definition_family
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = local.app_container_name
      image     = "${aws_ecr_repository.app.repository_url}:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "app"
        }
      }

      environment = [
        {
          name  = "APP_NAME"
          value = var.project_name
        },
        {
          name  = "APP_ENV"
          value = var.app_environment
        },
        {
          name  = "APP_VERSION"
          value = var.image_tag
        },
        {
          name  = "BUILD_ID"
          value = var.build_id
        },
        {
          name  = "BUILD_DATE"
          value = var.build_date
        }
      ]
    }
  ])
}
