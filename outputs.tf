# SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
# SPDX-License-Identifier: MIT

output "cluster_arn" {
  description = "ARN of the EKS cluster."
  value       = aws_eks_cluster.this.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate authority data for the cluster."
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes API server."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster."
  value       = aws_eks_cluster.this.name
}

output "cluster_oidc_issuer_url" {
  description = "Issuer URL of the cluster's OpenID Connect identity provider."
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "cluster_role_arn" {
  description = "ARN of the IAM role associated with the EKS cluster."
  value       = aws_iam_role.cluster.arn
}

output "cluster_security_group_id" {
  description = "ID of the security group EKS creates for the cluster and its nodes."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster."
  value       = aws_eks_cluster.this.version
}

output "log_group_name" {
  description = "Name of the CloudWatch log group that holds the control plane logs."
  value       = aws_cloudwatch_log_group.this.name
}

output "node_role_arn" {
  description = "ARN of the IAM role associated with the EKS nodes."
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "Name of the IAM role associated with the EKS nodes."
  value       = aws_iam_role.node.name
}
