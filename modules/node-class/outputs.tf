output "access_entry_principal_arn" {
  description = "Principal ARN of the EKS access entry."
  value       = var.create && var.role != null ? var.role : null
}

output "node_class_name" {
  description = "Name of the created NodeClass."
  value       = var.create ? var.name : null
}
