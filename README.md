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
