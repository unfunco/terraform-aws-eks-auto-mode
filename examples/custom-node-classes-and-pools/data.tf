data "aws_availability_zones" "these" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
