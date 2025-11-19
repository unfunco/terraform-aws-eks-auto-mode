output "node_pool_name" {
  description = "Name of the created NodePool."
  value       = var.create ? var.name : null
}
