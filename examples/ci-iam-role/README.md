# CI IAM role example

Creates an IAM policy scoped for managing the `workloads` cluster and attaches
it to a GitHub OIDC role for use in CI/CD pipelines.

Useful steps:

1. `terraform init` && `terraform apply`
2. Grant your workflow access to assume the created role and deploy the cluster
3. Rotate the cluster name or policy inputs per environment (dev/stage/prod)
