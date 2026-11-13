// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

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

variable "force_destroy" {
  default     = false
  description = "Force destroy resources."
  type        = bool
}

variable "kms_key_arn" {
  default     = null
  description = "ARN of the KMS key that encrypts Kubernetes secrets and control plane logs, unless a more specific key is given."
  type        = string
}

variable "kms_key_arn_cluster" {
  default     = null
  description = "ARN of the KMS key that encrypts Kubernetes secrets, in place of kms_key_arn."
  type        = string
}

variable "kms_key_arn_log_group" {
  default     = null
  description = "ARN of the KMS key that encrypts control plane logs, in place of kms_key_arn."
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
