data "aws_caller_identity" "this" {
  count = var.create ? 1 : 0
}

data "aws_partition" "this" {
  count = var.create ? 1 : 0
}

data "aws_region" "this" {
  count = var.create ? 1 : 0
}

data "aws_iam_policy_document" "cluster" {
  count = var.create ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession",
    ]

    principals {
      identifiers = ["eks.${data.aws_partition.this[0].dns_suffix}"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "node" {
  count = var.create ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ec2.${data.aws_partition.this[0].dns_suffix}"]
      type        = "Service"
    }
  }
}
