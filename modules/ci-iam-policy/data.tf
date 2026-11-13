// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

data "aws_caller_identity" "this" {}

data "aws_partition" "this" {}

data "aws_region" "this" {}

data "aws_iam_policy_document" "this" {
  # Neither action supports resource-level permissions. The roles a new
  # cluster can be given are still limited by the PassRolesToEKS statement.
  statement {
    sid = "CreateClusterAndFindLogGroup"

    actions = [
      "eks:CreateCluster",
      "logs:DescribeLogGroups",
    ]

    resources = ["*"]
  }

  statement {
    sid = "ManageCluster"

    actions = [
      "eks:AssociateEncryptionConfig",
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
    sid = "ManageRoles"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRolePolicies",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]

    resources = local.role_arns
  }

  statement {
    sid = "AttachManagedPolicies"

    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
    ]

    resources = local.role_arns

    condition {
      test     = "ArnEquals"
      values   = local.managed_policy_arns
      variable = "iam:PolicyARN"
    }
  }

  statement {
    sid       = "PassRolesToEKS"
    actions   = ["iam:PassRole"]
    resources = local.role_arns

    condition {
      test     = "StringEquals"
      values   = ["eks.${local.dns_suffix}"]
      variable = "iam:PassedToService"
    }
  }

  statement {
    sid       = "CreateServiceLinkedRole"
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["arn:${local.partition}:iam::${local.account_id}:role/aws-service-role/eks.${local.dns_suffix}/AWSServiceRoleForAmazonEKS"]

    condition {
      test     = "StringEquals"
      values   = ["eks.${local.dns_suffix}"]
      variable = "iam:AWSServiceName"
    }
  }

  statement {
    sid = "ManageLogGroup"

    actions = [
      "logs:AssociateKmsKey",
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DeleteRetentionPolicy",
      "logs:DisassociateKmsKey",
      "logs:ListTagsForResource",
      "logs:PutRetentionPolicy",
      "logs:TagResource",
      "logs:UntagResource",
    ]

    resources = [local.log_group_arn]
  }

  dynamic "statement" {
    for_each = length(var.kms_key_arns) > 0 ? [var.kms_key_arns] : []

    content {
      sid = "UseEncryptionKeys"

      actions = [
        "kms:CreateGrant",
        "kms:DescribeKey",
      ]

      resources = statement.value
    }
  }
}
