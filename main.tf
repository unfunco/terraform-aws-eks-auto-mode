// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

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

  enable_cluster_kms = var.kms_key_arn != null && var.kms_key_arn_cluster != null
}

resource "aws_cloudwatch_log_group" "this" {
  kms_key_id        = var.kms_key_arn_log_group != null ? var.kms_key_arn_log_group : var.kms_key_arn
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
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.node.arn
  }

  dynamic "encryption_config" {
    for_each = local.enable_cluster_kms ? { enabled = true } : {}

    content {
      resources = ["logs"]

      provider {
        key_arn = coalesce(var.kms_key_arn_log_group, var.kms_key_arn)
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
    subnet_ids = var.subnet_ids
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
