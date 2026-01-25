// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

data "aws_caller_identity" "this" {
  count = var.create ? 1 : 0
}

data "aws_partition" "this" {
  count = var.create ? 1 : 0
}

data "aws_region" "this" {
  count = var.create ? 1 : 0
}

data "aws_iam_policy_document" "this" {
  count = var.create ? 1 : 0

  version = "2012-10-17"

  statement {
    actions   = ["eks:CreateCluster"]
    effect    = "Allow"
    resources = ["*"]
  }

  statement {
    actions = toset([
      "eks:DeleteCluster",
      "eks:DescribeCluster",
      "eks:DescribeUpdate",
      "eks:ListUpdates",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
    ])

    effect    = "Allow"
    resources = [local.cluster_arn]
  }

  statement {
    actions = toset([
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:ListTagsForResource",
      "logs:PutRetentionPolicy",
      "logs:TagLogGroup",
      "logs:UntagLogGroup",
    ])

    effect    = "Allow"
    resources = [local.log_group_arn]
  }
}
