// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

locals {
  account_id = data.aws_caller_identity.this.account_id
  dns_suffix = data.aws_partition.this.dns_suffix
  partition  = data.aws_partition.this.partition
  region     = data.aws_region.this.region

  cluster_arn   = "arn:${local.partition}:eks:${local.region}:${local.account_id}:cluster/${var.cluster_name}"
  log_group_arn = "arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:/aws/eks/${var.cluster_name}/cluster*"

  role_arns = [
    "arn:${local.partition}:iam::${local.account_id}:role/${var.cluster_name}-cluster-role",
    "arn:${local.partition}:iam::${local.account_id}:role/${var.cluster_name}-node-role",
  ]

  # The managed policies the root module attaches to its two roles. Limiting
  # attachments to these stops the pipeline granting itself anything else.
  managed_policy_arns = [
    for name in [
      "AmazonEC2ContainerRegistryPullOnly",
      "AmazonEKSBlockStoragePolicy",
      "AmazonEKSClusterPolicy",
      "AmazonEKSComputePolicy",
      "AmazonEKSLoadBalancingPolicy",
      "AmazonEKSNetworkingPolicy",
      "AmazonEKSWorkerNodeMinimalPolicy",
    ] : "arn:${local.partition}:iam::aws:policy/${name}"
  ]
}
