locals {
  cluster_arn = format(
    "arn:%s:eks:%s:%s:cluster/%s",
    data.aws_partition.this[0].partition,
    data.aws_region.this[0].region,
    data.aws_caller_identity.this[0].account_id,
    var.cluster_name,
  )

  log_group_arn = format(
    "arn:%s:logs:%s:%s:log-group:/aws/eks/%s/cluster*",
    data.aws_partition.this[0].partition,
    data.aws_region.this[0].region,
    data.aws_caller_identity.this[0].account_id,
    var.cluster_name,
  )
}
