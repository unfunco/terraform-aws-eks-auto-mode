// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

data "aws_availability_zones" "these" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
