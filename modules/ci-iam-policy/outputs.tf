output "policy_document" {
  description = "IAM policy document granting least-privilege permissions to deploy this module."
  value       = try(data.aws_iam_policy_document.this[0], null)
}
