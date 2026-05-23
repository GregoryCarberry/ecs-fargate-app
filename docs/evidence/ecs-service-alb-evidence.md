# ECS service behind ALB evidence

Milestone: ECS Fargate service behind Application Load Balancer

Observed results:
- ALB returned HTTP 200 for /health
- ALB returned HTTP 200 for /
- ALB returned HTTP 200 for /version
- Target group health: healthy
- ECS service status: ACTIVE
- desiredCount: 1
- runningCount: 1
- pendingCount: 0
- CloudWatch logs showed repeated GET /health HTTP/1.1 200 OK entries

Notes:
- Account-specific ARNs, subnet IDs, security group IDs, and private IPs are intentionally not documented here for public use.
- Public README examples should use placeholders such as <aws_account_id>.
