# SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
# SPDX-License-Identifier: MIT

locals {
  cluster_role_policies = toset([
    "AmazonEKSBlockStoragePolicy",
    "AmazonEKSClusterPolicy",
    "AmazonEKSComputePolicy",
    "AmazonEKSLoadBalancingPolicy",
    "AmazonEKSNetworkingPolicy",
  ])

  node_role_policies = toset([
    "AmazonEC2ContainerRegistryPullOnly",
    "AmazonEKSWorkerNodeMinimalPolicy",
  ])

  kms_key_arn_cluster   = var.kms_key_arn_cluster != null ? var.kms_key_arn_cluster : var.kms_key_arn
  kms_key_arn_log_group = var.kms_key_arn_log_group != null ? var.kms_key_arn_log_group : var.kms_key_arn
}

resource "aws_cloudwatch_log_group" "this" {
  kms_key_id        = local.kms_key_arn_log_group
  log_group_class   = var.log_group_class
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_in_days
  skip_destroy      = !var.force_destroy
  tags              = var.tags
}

resource "aws_eks_cluster" "this" {
  # EKS creates the log group itself, without encryption or retention, when
  # it does not already exist, and it needs the role policies both to create
  # the cluster's infrastructure and to clean it up again on destroy.
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.node,
  ]

  bootstrap_self_managed_addons = false
  enabled_cluster_log_types     = var.cluster_log_types
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.cluster.arn
  tags                          = var.tags
  version                       = var.cluster_version

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  compute_config {
    enabled       = true
    node_pools    = var.node_pools
    node_role_arn = aws_iam_role.node.arn
  }

  dynamic "encryption_config" {
    for_each = local.kms_key_arn_cluster[*]

    content {
      resources = ["secrets"]

      provider {
        key_arn = encryption_config.value
      }
    }
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = length(var.endpoint_public_access_cidrs) > 0
    public_access_cidrs     = length(var.endpoint_public_access_cidrs) > 0 ? var.endpoint_public_access_cidrs : null
    subnet_ids              = var.subnet_ids
  }
}

resource "aws_iam_role" "cluster" {
  assume_role_policy    = data.aws_iam_policy_document.cluster.json
  description           = "Assumed by EKS to manage clusters."
  force_detach_policies = var.force_destroy
  name                  = "${var.cluster_name}-cluster-role"
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = local.cluster_role_policies

  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/${each.key}"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role" "node" {
  assume_role_policy    = data.aws_iam_policy_document.node.json
  description           = "Assumed by EC2 instances to join EKS clusters."
  force_detach_policies = var.force_destroy
  name                  = "${var.cluster_name}-node-role"
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = local.node_role_policies

  policy_arn = "arn:${data.aws_partition.this.partition}:iam::aws:policy/${each.key}"
  role       = aws_iam_role.node.name
}
