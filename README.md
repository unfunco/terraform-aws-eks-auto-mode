# Terraform module for Amazon EKS Auto Mode

[![CI](https://github.com/unfunco/terraform-aws-eks-auto-mode/actions/workflows/ci.yaml/badge.svg)](https://github.com/unfunco/terraform-aws-eks-auto-mode/actions/workflows/ci.yaml)
[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-unfunco%2Feks--auto--mode-blue?logo=terraform)](https://registry.terraform.io/modules/unfunco/eks-auto-mode/aws)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE.md)

Terraform module for provisioning Kubernetes clusters
using [Amazon EKS Auto Mode].

## Getting started

### Requirements

- [AWS Command Line Interface] 2+
- [Terraform] 1.14+
- [Terraform AWS provider] 6.0+
- [Terraform Kubernetes provider] 3.0+

### Installation and usage

<!-- x-release-please-start-version -->

```terraform
module "workloads" {
  source  = "unfunco/eks-auto-mode/aws"
  version = "0.0.0"

  cluster_name = "workloads"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
}
```

<!-- x-release-please-end -->

```bash
aws eks update-kubeconfig --name workloads
```

This is what the cluster looks like once created:

```bash
$ kubectl get ns
NAME              STATUS   AGE
default           Active   6m4s
kube-node-lease   Active   6m4s
kube-public       Active   6m4s
kube-system       Active   6m4s

$ kubectl get all -A

NAMESPACE     NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
default       service/kubernetes                  ClusterIP   172.20.0.1       <none>        443/TCP   9m15s
kube-system   service/eks-extension-metrics-api   ClusterIP   172.20.164.128   <none>        443/TCP   9m14s

$ kubectl get cm -A
NAMESPACE         NAME                                                   DATA   AGE
default           kube-root-ca.crt                                       1      9m25s
kube-node-lease   kube-root-ca.crt                                       1      9m25s
kube-public       kube-root-ca.crt                                       1      9m25s
kube-system       extension-apiserver-authentication                     6      9m38s
kube-system       kube-apiserver-legacy-service-account-token-tracking   1      9m38s
kube-system       kube-root-ca.crt                                       1      9m25s
```

#### Custom node classes

<!-- x-release-please-start-version -->

```terraform
module "workloads" {
  source  = "unfunco/eks-auto-mode/aws"
  version = "0.0.0"

  cluster_name = "workloads"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
}

module "custom_node_class" {
  source  = "unfunco/eks-auto-mode/aws//modules/node-class"
  version = "0.0.0"

  cluster_name = module.workloads.cluster_name
  name         = "custom-node-class"
  role         = module.workloads.node_role_arn

  subnet_selector_terms = [
    {
      tags = {
        "kubernetes.io/role/internal-elb" = "1"
      }
    }
  ]

  security_group_selector_terms = [
    {
      tags = {
        "aws:eks:cluster-name" = module.workloads.cluster_name
      }
    }
  ]

  ephemeral_storage = {
    size = "100Gi"
  }
}
```

<!-- x-release-please-end -->

#### IAM role for CI/CD pipelines

A submodule is provided that creates an IAM policy for CI/CD pipelines that
need to deploy and manage the EKS clusters. This policy can be attached to an
IAM role created by another module, such as [unfunco/oidc-github], for example:

<!-- x-release-please-start-version -->

```terraform
module "eks_deployer_iam_policy" {
  source = "unfunco/eks-auto-mode/aws//modules/ci-iam-policy"
  version = "0.0.0"

  cluster_name = "workloads"
}
```

<!-- x-release-please-end -->

```terraform
module "oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "3.0.0"

  github_subjects = ["unfunco/example"]
  iam_role_inline_policies = {
    eks = module.eks_deployer_iam_policy.policy_document.json
  }
}
```

<!-- BEGIN_TF_DOCS -->

### Resources

| Name                                                                                                                                             | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------ | ----------- |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                | resource    |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster)                                  | resource    |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                     | resource    |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                        | resource    |
| [aws_iam_role_policy_attachment.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_role_policy_attachment.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)    | resource    |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                       | data source |
| [aws_iam_policy_document.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |
| [aws_iam_policy_document.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)               | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                   | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                         | data source |

### Inputs

| Name                  | Description                                         | Type           | Default                                                                 | Required |
| --------------------- | --------------------------------------------------- | -------------- | ----------------------------------------------------------------------- | :------: |
| cluster_log_types     | Control plane logging types to enable.              | `list(string)` | `[ "api", "audit", "authenticator", "controllerManager", "scheduler" ]` |    no    |
| cluster_name          | Kubernetes cluster name.                            | `string`       | n/a                                                                     |   yes    |
| cluster_version       | Kubernetes cluster version.                         | `string`       | `"1.34"`                                                                |    no    |
| create                | Enable/disable the creation of all resources.       | `bool`         | `true`                                                                  |    no    |
| force_destroy         | Force destroy resources.                            | `bool`         | `false`                                                                 |    no    |
| kms_key_arn           | n/a                                                 | `string`       | `null`                                                                  |    no    |
| kms_key_arn_cluster   | ARN of the KMS key to use cluster encryption.       | `string`       | `null`                                                                  |    no    |
| kms_key_arn_log_group | ARN of the KMS key to use for log group encryption. | `string`       | `null`                                                                  |    no    |
| log_group_class       | Log group storage class.                            | `string`       | `"STANDARD"`                                                            |    no    |
| log_retention_in_days | Days to retain logs in CloudWatch Logs.             | `number`       | `365`                                                                   |    no    |
| subnet_ids            | Subnet IDs for the EKS cluster.                     | `list(string)` | n/a                                                                     |   yes    |
| tags                  | Tags to be applied to all applicable resources.     | `map(string)`  | `{}`                                                                    |    no    |

### Outputs

| Name             | Description                                          |
| ---------------- | ---------------------------------------------------- |
| cluster_arn      | ARN of the EKS cluster.                              |
| cluster_name     | Name of the EKS cluster.                             |
| cluster_role_arn | ARN of the IAM role associated with the EKS cluster. |
| node_role_arn    | ARN of the IAM role associated with the EKS nodes.   |

<!-- END_TF_DOCS -->

### Releases

This repository uses [Release Please] to automate releases. When pull requests
with [conventional commit] messages are merged, Release Please will open or
update a pull request to bump the version and update the changelog. Once that
pull request is merged, a new release will be created.

## License

© 2025 [Daniel Morris]\
Made available under the terms of the [MIT License].

[amazon eks auto mode]: https://aws.amazon.com/eks/auto-mode/
[aws command line interface]: https://aws.amazon.com/cli/
[conventional commit]: https://www.conventionalcommits.org
[daniel morris]: https://unfun.co
[mit license]: LICENSE.md
[release please]: https://github.com/googleapis/release-please
[terraform]: https://www.terraform.io
[terraform aws provider]: https://registry.terraform.io/providers/hashicorp/aws
[terraform kubernetes provider]: https://registry.terraform.io/providers/hashicorp/kubernetes
[unfunco/oidc-github]: https://registry.terraform.io/modules/unfunco/oidc-github/aws/latest
