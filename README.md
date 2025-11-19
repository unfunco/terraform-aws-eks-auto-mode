# Terraform module for Amazon EKS Auto Mode

[![CI](https://github.com/unfunco/terraform-aws-eks-auto-mode/actions/workflows/ci.yaml/badge.svg)](https://github.com/unfunco/terraform-aws-eks-auto-mode/actions/workflows/ci.yaml)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE.md)

Terraform module for provisioning Kubernetes clusters
using [Amazon EKS Auto Mode].

EKS Auto Mode extends AWS management of Kubernetes clusters beyond the cluster
to allow AWS to also set up and manage the infrastructure that enables
the smooth operation of your workloads. Cluster infrastructure managed by AWS
includes many Kubernetes capabilities as core components such as compute
autoscaling, pod and service networking, application load balancing, cluster
DNS, block storage, and GPU support.

## Getting started

### Requirements

- [AWS Command Line Interface] 2+
- [Terraform] 1.13+
- [Terraform AWS provider] 6.0+

### Installation and usage

The `x-release-please-version` comments in the examples can be ignored; they are
used by [Release Please] to automatically update the version numbers when
releasing new versions.

```terraform
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      project     = "platform"
      environment = "dev"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name               = "workloads"
  cidr               = "10.0.0.0/16"
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
  public_subnets = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  intra_subnets = ["10.0.30.0/24", "10.0.31.0/24", "10.0.32.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/workloads" = "shared"
  }

  intra_subnet_tags = {
    # Used later for pod ENIs when we create a custom NodeClass.
    "kubernetes.io/role/pod-eni"      = 1
    "kubernetes.io/cluster/workloads" = "shared"
  }
}

module "workloads" {
  source = "unfunco/eks-auto-mode/aws"
  version = "0.0.0" // x-release-please-version

  cluster_name    = "workloads"
  cluster_version = "1.30"
  subnet_ids      = module.network.private_subnets

  tags = {
    owner       = "platform-team"
    environment = "dev"
  }
}

data "aws_eks_cluster" "workloads" {
  name = module.workloads.cluster_name
  depends_on = [module.workloads]
}

data "aws_eks_cluster_auth" "workloads" {
  name = module.workloads.cluster_name
  depends_on = [module.workloads]
}

provider "kubernetes" {
  host  = data.aws_eks_cluster.workloads.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.workloads.certificate_authority[0].data)
  token = data.aws_eks_cluster_auth.workloads.token
}
```

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

```terraform
module "custom_node_class" {
  source = "unfunco/eks-auto-mode/aws//modules/node-class"
  version = "0.0.0" // x-release-please-version

  cluster_name = module.workloads.cluster_name
  name         = "private-app-nodes"
  role         = module.workloads.node_role_arn

  subnet_selector_terms = [
    for subnet_id in module.network.private_subnets : { id = subnet_id }
  ]

  pod_subnet_selector_terms = [
    for subnet_id in module.network.intra_subnets : { id = subnet_id }
  ]

  security_group_selector_terms = [
    {
      tags = {
        # Matches the managed security group that EKS creates for the cluster.
        "aws:eks:cluster-name" = module.workloads.cluster_name
      }
    }
  ]

  advanced_security = {
    fips = true
  }

  ephemeral_storage = {
    size       = "200Gi"
    throughput = 1000
  }

  tags = {
    "eks.amazonaws.com/nodegroup" = "private-app"
    "owner"                       = "platform-team"
  }
}

module "private_app_node_pool" {
  source = "unfunco/eks-auto-mode/aws//modules/node-pool"
  version = "0.0.0" // x-release-please-version

  name            = "private-app"
  node_class_name = module.custom_node_class.node_class_name

  labels = {
    workload = "private-app"
  }

  requirements = [
    {
      key      = "eks.amazonaws.com/instance-category"
      operator = "In"
      values = ["c", "m"]
    },
    {
      key      = "eks.amazonaws.com/instance-cpu"
      operator = "In"
      values = ["4", "8", "16"]
    },
    {
      key      = "kubernetes.io/arch"
      operator = "In"
      values = ["arm64", "amd64"]
    },
  ]

  limits = {
    cpu    = "500"
    memory = "400Gi"
  }

  disruption = {
    consolidation_policy = "WhenUnderutilized"
    budgets = [
      {
        nodes    = "10%"
        duration = "10m"
      }
    ]
  }

  expire_after = "336h"
  weight       = 50
}
```

#### IAM role for CI/CD pipelines

A submodule is provided that creates an IAM policy for CI/CD pipelines that
need to deploy and manage the EKS clusters. This policy can be attached to an
IAM role created by another module, such as [unfunco/oidc-github], for example:

```terraform
module "eks_deployer_iam_policy" {
  source = "unfunco/eks-auto-mode/aws//modules/ci-iam-policy"
  version = "0.0.0" // x-release-please-version

  cluster_name = "workloads"
}

module "oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "2.0.2"

  github_repositories = ["unfunco/example"]
  iam_role_inline_policies = {
    eks = module.eks_deployer_iam_policy.policy_document.json
  }
}
```

<!-- BEGIN_TF_DOCS -->

### Resources

| Name                                                                                                                                             | Type        |
|--------------------------------------------------------------------------------------------------------------------------------------------------|-------------|
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
|-----------------------|-----------------------------------------------------|----------------|-------------------------------------------------------------------------|:--------:|
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
|------------------|------------------------------------------------------|
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

[unfunco/oidc-github]: https://registry.terraform.io/modules/unfunco/oidc-github/aws/latest
