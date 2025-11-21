variable "cluster_name" {
  description = "Cluster name."
  type        = string
}

variable "create" {
  default     = true
  description = "Enable/disable the creation of all resources."
  type        = bool
}
