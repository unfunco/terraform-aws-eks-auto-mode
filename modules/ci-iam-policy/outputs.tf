// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

output "json" {
  description = "IAM policy document, as JSON, that grants the permissions needed to deploy the root module."
  value       = data.aws_iam_policy_document.this.json
}
