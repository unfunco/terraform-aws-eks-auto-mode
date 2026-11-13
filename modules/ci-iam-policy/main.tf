// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

locals {
  account_id = data.aws_caller_identity.this.account_id
  partition  = data.aws_partition.this.partition
  region     = data.aws_region.this.region

  cluster_arn   = "arn:${local.partition}:eks:${local.region}:${local.account_id}:cluster/${var.cluster_name}"
  log_group_arn = "arn:${local.partition}:logs:${local.region}:${local.account_id}:log-group:/aws/eks/${var.cluster_name}/cluster*"
}
