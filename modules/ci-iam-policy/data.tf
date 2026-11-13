// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

data "aws_caller_identity" "this" {}

data "aws_partition" "this" {}

data "aws_region" "this" {}

data "aws_iam_policy_document" "this" {
  statement {
    actions   = ["eks:CreateCluster"]
    resources = ["*"]
  }

  statement {
    actions = [
      "eks:DeleteCluster",
      "eks:DescribeCluster",
      "eks:DescribeUpdate",
      "eks:ListUpdates",
      "eks:TagResource",
      "eks:UntagResource",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion",
    ]

    resources = [local.cluster_arn]
  }

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DescribeLogGroups",
      "logs:ListTagsForResource",
      "logs:PutRetentionPolicy",
      "logs:TagLogGroup",
      "logs:UntagLogGroup",
    ]

    resources = [local.log_group_arn]
  }
}
