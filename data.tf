// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

data "aws_partition" "this" {}

data "aws_iam_policy_document" "cluster" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      identifiers = ["eks.${data.aws_partition.this.dns_suffix}"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "node" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.${data.aws_partition.this.dns_suffix}"]
      type        = "Service"
    }
  }
}
