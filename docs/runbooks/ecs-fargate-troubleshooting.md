# ECS Fargate Troubleshooting Runbook

This runbook is for the ECS Fargate Operational Readiness Lab in `eu-west-2`. It is written as a practical first-line troubleshooting guide to demonstrate junior cloud support and technical support skills: confirm the symptom, gather evidence, narrow the fault domain, and apply the safest fix.

## Quick checks

Start with the smallest set of checks that tells you where the fault sits.

Public ALB checks:

```bash
curl -i http://<alb_dns_name>/health
curl -i http://<alb_dns_name>/
curl -i http://<alb_dns_name>/version
```

Target health:

```bash
aws elbv2 describe-target-health \
  --region eu-west-2 \
  --target-group-arn <target_group_arn>
```

ECS service state:

```bash
aws ecs describe-services \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --services <service_name>
```

Task list:

```bash
aws ecs list-tasks \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --service-name <service_name>
```

CloudWatch log streams:

```bash
aws logs describe-log-streams \
  --region eu-west-2 \
  --log-group-name <log_group_name> \
  --order-by LastEventTime \
  --descending
```

Recent log events:

```bash
aws logs get-log-events \
  --region eu-west-2 \
  --log-group-name <log_group_name> \
  --log-stream-name <log_stream_name>
```

## ALB returns 503

What it usually means:

- the ALB listener is reachable, but there are no healthy targets behind the target group
- the ECS service may not have any running tasks
- the app may be listening on the wrong port or failing health checks

What to check:

```bash
aws elbv2 describe-target-health \
  --region eu-west-2 \
  --target-group-arn <target_group_arn>

aws ecs describe-services \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --services <service_name>
```

What good looks like:

- target health state is `healthy`
- ECS service is `ACTIVE`
- `desiredCount` is `1`
- `runningCount` is `1`
- `pendingCount` is `0`

Likely fixes:

- if there are no targets, check why the ECS service is not running a task
- if targets exist but are unhealthy, move to the unhealthy target section below
- confirm the service is registering the correct container name and container port `8000`

## Target group shows unhealthy targets

What it usually means:

- the task is running but not passing the ALB health check
- the app is not answering `GET /health` with HTTP `200`
- the ALB security group or ECS task security group may be blocking traffic on port `8000`

What to check:

```bash
aws elbv2 describe-target-health \
  --region eu-west-2 \
  --target-group-arn <target_group_arn>

curl -i http://<alb_dns_name>/health
```

Then inspect service and task details:

```bash
aws ecs describe-services \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --services <service_name>

aws ecs describe-tasks \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --tasks <task_arn>
```

Checks to make:

- health check path is `/health`
- container is listening on port `8000`
- ECS task security group allows inbound TCP `8000` from the ALB security group
- the app has started cleanly and is not crashing during boot

Useful evidence:

- target health reason codes from `describe-target-health`
- application logs from CloudWatch showing startup or request failures

## ECS service desiredCount is 1 but runningCount is 0

What it usually means:

- ECS is trying to run a task but the task cannot stay up
- the task may be failing placement, failing startup, or exiting immediately

What to check:

```bash
aws ecs describe-services \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --services <service_name>

aws ecs list-tasks \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --service-name <service_name>
```

Focus on:

- `events` in the ECS service output
- whether tasks briefly appear and then stop
- whether the service is `ACTIVE` but cannot maintain a running task

Next steps:

- inspect stopped task reasons with `describe-tasks`
- check CloudWatch logs for application startup errors
- check ECR pull access and image tag correctness

## ECS task fails to start

What it usually means:

- the task definition points to a bad image tag
- the task execution role cannot pull from ECR or write to CloudWatch Logs
- the container exits during startup because of an application error

What to check:

```bash
aws ecs describe-tasks \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --tasks <task_arn>
```

Look for:

- `lastStatus`
- `stoppedReason`
- container `reason`
- exit codes

Then confirm the task definition image reference:

```bash
aws ecs describe-task-definition \
  --region eu-west-2 \
  --task-definition <task_definition>
```

Practical fixes:

- verify the image tag exists in ECR
- confirm the task execution role has the standard ECS task execution policy attached
- review app logs to see whether the process failed after container startup

## Image pull or ECR access problems

What it usually means:

- the image tag does not exist
- the task definition points at the wrong repository URL
- the task execution role cannot authenticate and pull from ECR

What to check:

```bash
aws ecr describe-images \
  --region eu-west-2 \
  --repository-name ecs-fargate-readiness-lab \
  --image-ids imageTag=0.1.0
```

If you need to push the image again manually:

```bash
aws ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com
docker tag ecs-fargate-lab:latest <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/ecs-fargate-readiness-lab:0.1.0
docker push <aws_account_id>.dkr.ecr.eu-west-2.amazonaws.com/ecs-fargate-readiness-lab:0.1.0
```

Checks to make:

- the repository exists
- the expected image tag exists
- the task definition image URL matches the ECR repository URL and tag
- the ECS task execution role can use ECR and CloudWatch Logs

## CloudWatch logs are missing or empty

What it usually means:

- the container never started
- the task execution role cannot create log streams or write log events
- the log group or log configuration is wrong

What to check:

```bash
aws logs describe-log-streams \
  --region eu-west-2 \
  --log-group-name <log_group_name> \
  --order-by LastEventTime \
  --descending

aws logs get-log-events \
  --region eu-west-2 \
  --log-group-name <log_group_name> \
  --log-stream-name <log_stream_name>
```

Checks to make:

- the log group name in the task definition matches the deployed log group
- log streams are being created
- the task execution role has the standard execution policy attached
- the task is reaching the point where the container emits logs

If there are no streams at all:

- check whether the task is failing before container startup
- inspect ECS stopped task reasons first

## App route returns an unexpected status

What it usually means:

- the container is up, but the route behaviour is not what you expect
- the app version or build metadata may not match the deployed image
- the health check may pass while another route still fails

What to check:

```bash
curl -i http://<alb_dns_name>/health
curl -i http://<alb_dns_name>/
curl -i http://<alb_dns_name>/version
```

Then compare with logs:

```bash
aws logs get-log-events \
  --region eu-west-2 \
  --log-group-name <log_group_name> \
  --log-stream-name <log_stream_name>
```

Checks to make:

- `/health` returns `200`
- `/` returns the expected service information
- `/version` returns the expected version and build values
- the deployed image tag matches the intended release

## Safe destroy and cost-control checks

This lab uses a live ECS service and an internet-facing ALB, so it can continue to incur charges after testing.

Before destroy:

```bash
aws ecs describe-services \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --services <service_name>
```

Confirm you are deleting the correct lab environment, then destroy from the Terraform directory:

```bash
cd infrastructure/environments/dev
terraform destroy
```

After destroy, check that the service and ALB are gone:

```bash
aws ecs describe-services \
  --region eu-west-2 \
  --cluster <cluster_name> \
  --services <service_name>

aws elbv2 describe-target-health \
  --region eu-west-2 \
  --target-group-arn <target_group_arn>
```

Good operational habits:

- keep screenshots or CLI output for evidence
- note the exact symptom, time, and command used
- confirm the fix with a fresh `curl` and a fresh AWS CLI check rather than assuming success
