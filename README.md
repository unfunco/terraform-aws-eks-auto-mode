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
- [Terraform AWS provider] 6.67.0+

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

The identity that creates the cluster is made a cluster administrator, so it
can connect straight away:

```bash
aws eks update-kubeconfig --name workloads
```

The outputs carry everything the [Terraform Kubernetes provider] or the
[Terraform Helm provider] need to deploy to the cluster from the same
configuration:

```terraform
provider "kubernetes" {
  cluster_ca_certificate = base64decode(module.workloads.cluster_certificate_authority_data)
  host                   = module.workloads.cluster_endpoint

  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", module.workloads.cluster_name]
    command     = "aws"
  }
}
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
| [aws_iam_policy_document.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)            | data source |
| [aws_iam_policy_document.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)               | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                   | data source |

### Inputs

| Name                         | Description                                                                                                                                                                       | Type          | Default                                                                 | Required |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------- | ----------------------------------------------------------------------- | :------: |
| cluster_log_types            | Control plane log types to send to CloudWatch Logs.                                                                                                                               | `set(string)` | `[ "api", "audit", "authenticator", "controllerManager", "scheduler" ]` |    no    |
| cluster_name                 | Name of the EKS cluster, which also prefixes the names of its IAM roles.                                                                                                          | `string`      | n/a                                                                     |   yes    |
| cluster_version              | Kubernetes minor version, such as 1.37. EKS chooses its current default when this is not set, and the cluster then stays on that version.                                         | `string`      | `null`                                                                  |    no    |
| endpoint_public_access_cidrs | CIDR blocks that can reach the public Kubernetes API endpoint. An empty list turns the public endpoint off, leaving the API reachable only from within the VPC.                   | `set(string)` | `[ "0.0.0.0/0" ]`                                                       |    no    |
| force_destroy                | Delete the control plane logs with the cluster, and detach any policies added to the IAM roles outside this module so the roles can be deleted. Logs are kept when this is false. | `bool`        | `false`                                                                 |    no    |
| kms_key_arn                  | ARN of the KMS key that encrypts Kubernetes secrets and control plane logs, unless a more specific key is given.                                                                  | `string`      | `null`                                                                  |    no    |
| kms_key_arn_cluster          | ARN of the KMS key that encrypts Kubernetes secrets, in place of kms_key_arn.                                                                                                     | `string`      | `null`                                                                  |    no    |
| kms_key_arn_log_group        | ARN of the KMS key that encrypts control plane logs, in place of kms_key_arn.                                                                                                     | `string`      | `null`                                                                  |    no    |
| log_group_class              | Storage class of the control plane log group, either STANDARD or INFREQUENT_ACCESS.                                                                                               | `string`      | `"STANDARD"`                                                            |    no    |
| log_retention_in_days        | Days to keep control plane logs in CloudWatch Logs.                                                                                                                               | `number`      | `365`                                                                   |    no    |
| node_pools                   | Built-in EKS Auto Mode node pools to enable. Nodes are only launched for a pool once pods are scheduled to it.                                                                    | `set(string)` | `[ "general-purpose", "system" ]`                                       |    no    |
| subnet_ids                   | IDs of the subnets, in at least two Availability Zones, where EKS places the control plane network interfaces and Auto Mode launches nodes.                                       | `set(string)` | n/a                                                                     |   yes    |
| tags                         | Tags to be applied to all applicable resources.                                                                                                                                   | `map(string)` | `{}`                                                                    |    no    |

### Outputs

| Name                               | Description                                                         |
| ---------------------------------- | ------------------------------------------------------------------- |
| cluster_arn                        | ARN of the EKS cluster.                                             |
| cluster_certificate_authority_data | Base64-encoded certificate authority data for the cluster.          |
| cluster_endpoint                   | Endpoint of the Kubernetes API server.                              |
| cluster_name                       | Name of the EKS cluster.                                            |
| cluster_oidc_issuer_url            | Issuer URL of the cluster's OpenID Connect identity provider.       |
| cluster_role_arn                   | ARN of the IAM role associated with the EKS cluster.                |
| cluster_security_group_id          | ID of the security group EKS creates for the cluster and its nodes. |
| cluster_version                    | Kubernetes version of the EKS cluster.                              |
| log_group_name                     | Name of the CloudWatch log group that holds the control plane logs. |
| node_role_arn                      | ARN of the IAM role associated with the EKS nodes.                  |
| node_role_name                     | Name of the IAM role associated with the EKS nodes.                 |

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
[terraform helm provider]: https://registry.terraform.io/providers/hashicorp/helm
[terraform kubernetes provider]: https://registry.terraform.io/providers/hashicorp/kubernetes
[unfunco/oidc-github]: https://registry.terraform.io/modules/unfunco/oidc-github/aws/latest
