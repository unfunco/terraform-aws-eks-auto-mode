data "aws_partition" "this" {
  count = var.create ? 1 : 0
}
