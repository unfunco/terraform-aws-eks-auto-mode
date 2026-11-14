# CI IAM role example

Creates an IAM role that GitHub Actions workflows in this repository can assume
through OpenID Connect. Its inline policy comes from the `ci-iam-policy`
submodule, and lets a pipeline deploy a cluster named `workloads` with the root
module. The [unfunco/oidc-github] module names the role `GitHubActions` and
creates the account's GitHub OIDC provider as well.

```bash
terraform init
```

```bash
terraform apply
```

An account can only have one OIDC provider for GitHub, so when it already has
one, set `create_oidc_provider = false` on the `oidc_github` module. The policy
covers the cluster, its two IAM roles and its log group, and nothing else, so
the role also needs access to wherever the pipeline keeps its Terraform state.

[unfunco/oidc-github]: https://registry.terraform.io/modules/unfunco/oidc-github/aws/latest
