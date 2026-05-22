# Containerised App on ECS Fargate

This repository is being built as a minimal ECS Fargate Operational Readiness Lab. The first step is a small Python FastAPI service designed for container deployment and local Docker testing before any infrastructure is added.

## Local app

The application lives under `app/` and exposes:

- `GET /` for basic service information
- `GET /health` for container and ALB health checks
- `GET /version` for app version and build metadata

## Run locally with Docker

Build the image:

```bash
docker build -t ecs-fargate-lab ./app
```

Run the container:

```bash
docker run --rm -p 8000:8000 ecs-fargate-lab
```

Test the endpoints:

```bash
curl http://localhost:8000/
curl http://localhost:8000/health
curl http://localhost:8000/version
```

Optional build metadata can be passed at runtime:

```bash
docker run --rm -p 8000:8000 \
  -e APP_VERSION=0.1.0 \
  -e BUILD_ID=local \
  ecs-fargate-lab
```

## Terraform: ECR foundation

The current infrastructure stage creates the ECR repository only.

```bash
cd infrastructure/environments/dev
terraform init
terraform validate
terraform plan
terraform apply
```

This stage does not yet create ECS, ALB, IAM, CloudWatch, or GitHub Actions.

## Push image to ECR

Push the local image to the existing repository:
Replace `<aws_account_id>` with your AWS account ID before running these commands.

```bash
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com
docker tag ecs-fargate-lab:latest <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/ecs-fargate-readiness-lab:0.1.0
docker push <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/ecs-fargate-readiness-lab:0.1.0
aws ecr describe-images --region eu-west-2 --repository-name ecs-fargate-readiness-lab --image-ids imageTag=0.1.0
```

Image tag `0.1.0` has been successfully pushed as the first manual deployment milestone.
