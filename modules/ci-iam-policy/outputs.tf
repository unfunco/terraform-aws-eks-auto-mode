// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

output "policy_document" {
  description = "IAM policy document granting least-privilege permissions to deploy this module."
  value       = try(data.aws_iam_policy_document.this[0], null)
}
