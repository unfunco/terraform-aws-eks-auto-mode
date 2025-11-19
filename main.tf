locals {
  default_cluster_role_policy_attachments = [
    "AmazonEKSBlockStoragePolicy",
    "AmazonEKSClusterPolicy",
    "AmazonEKSComputePolicy",
    "AmazonEKSLoadBalancingPolicy",
    "AmazonEKSNetworkingPolicy",
  ]

  default_node_role_policy_attachments = [
    "AmazonEC2ContainerRegistryPullOnly",
    "AmazonEKSWorkerNodeMinimalPolicy",
  ]

  default_tags = merge({}, var.tags)

  enable_cluster_kms = var.kms_key_arn != null && var.kms_key_arn_cluster != null
}

resource "aws_cloudwatch_log_group" "this" {
  count = var.create ? 1 : 0

  kms_key_id        = var.kms_key_arn_log_group != null ? var.kms_key_arn_log_group : var.kms_key_arn
  log_group_class   = var.log_group_class
  name              = format("/aws/eks/%s/cluster", var.cluster_name)
  retention_in_days = var.log_retention_in_days
  skip_destroy      = !var.force_destroy
  tags              = local.default_tags
}

resource "aws_eks_cluster" "this" {
  count = var.create ? 1 : 0

  bootstrap_self_managed_addons = false
  enabled_cluster_log_types     = var.cluster_log_types
  force_update_version          = false
  name                          = var.cluster_name
  role_arn                      = aws_iam_role.cluster[0].arn
  tags                          = local.default_tags
  version                       = var.cluster_version

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.node[0].arn
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
  count = var.create ? 1 : 0

  assume_role_policy    = data.aws_iam_policy_document.cluster[0].json
  description           = "Assumed by EKS to manage clusters."
  force_detach_policies = var.force_destroy
  name                  = format("%s-cluster-role", var.cluster_name)
  tags                  = local.default_tags
}

resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = var.create ? toset(local.default_cluster_role_policy_attachments) : []

  policy_arn = format("arn:%s:iam::aws:policy/%s", data.aws_partition.this[0].partition, each.key)
  role       = aws_iam_role.cluster[0].name
}

resource "aws_iam_role" "node" {
  count = var.create ? 1 : 0

  assume_role_policy    = data.aws_iam_policy_document.node[0].json
  description           = "Assumed by EC2 instances to join EKS clusters."
  force_detach_policies = var.force_destroy
  name                  = format("%s-node-role", var.cluster_name)
  tags                  = local.default_tags
}

resource "aws_iam_role_policy_attachment" "node" {
  for_each = var.create ? toset(local.default_node_role_policy_attachments) : []

  policy_arn = format("arn:%s:iam::aws:policy/%s", data.aws_partition.this[0].partition, each.key)
  role       = aws_iam_role.node[0].name
}
