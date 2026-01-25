// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = var.create ? aws_eks_cluster.this[0].arn : null
}

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = var.create ? aws_eks_cluster.this[0].name : null
}

output "cluster_role_arn" {
  description = "ARN of the IAM role associated with the EKS cluster."
  value       = var.create ? aws_iam_role.cluster[0].arn : null
}

output "node_role_arn" {
  description = "ARN of the IAM role associated with the EKS nodes."
  value       = var.create ? aws_iam_role.node[0].arn : null
}
