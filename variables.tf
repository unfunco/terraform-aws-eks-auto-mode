variable "cluster_log_types" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "Control plane logging types to enable."
  type        = list(string)
}

variable "cluster_name" {
  description = "Kubernetes cluster name."
  type        = string
}

variable "cluster_version" {
  default     = "1.34"
  description = "Kubernetes cluster version."
  type        = string
}

variable "create" {
  default     = true
  description = "Enable/disable the creation of all resources."
  type        = bool
}

variable "force_destroy" {
  default     = false
  description = "Force destroy resources."
  type        = bool
}

variable "kms_key_arn" {
  default     = null
  description = ""
  type        = string
}

variable "kms_key_arn_cluster" {
  default     = null
  description = "ARN of the KMS key to use cluster encryption."
  type        = string
}

variable "kms_key_arn_log_group" {
  default     = null
  description = "ARN of the KMS key to use for log group encryption."
  type        = string
}

variable "log_group_class" {
  default     = "STANDARD"
  description = "Log group storage class."
  type        = string
}

variable "log_retention_in_days" {
  default     = 365
  description = "Days to retain logs in CloudWatch Logs."
  type        = number
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS cluster."
  type        = list(string)
}

variable "tags" {
  default     = {}
  description = "Tags to be applied to all applicable resources."
  type        = map(string)
}
