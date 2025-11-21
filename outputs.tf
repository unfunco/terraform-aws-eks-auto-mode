output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = var.create ? aws_eks_cluster.this[0].arn : null
}
