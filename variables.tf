# SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
# SPDX-License-Identifier: MIT

variable "cluster_log_types" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "Control plane log types to send to CloudWatch Logs."
  type        = set(string)

  validation {
    condition = alltrue([
      for log_type in var.cluster_log_types :
      contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], log_type)
    ])
    error_message = "Each log type must be one of api, audit, authenticator, controllerManager or scheduler."
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster, which also prefixes the names of its IAM roles."
  type        = string

  validation {
    condition     = can(regex("^[0-9A-Za-z][0-9A-Za-z_-]{0,50}$", var.cluster_name))
    error_message = "The cluster name must start with a letter or a digit, contain only letters, digits, hyphens and underscores, and be at most 51 characters long so the IAM role names fit in 64."
  }
}

variable "cluster_version" {
  default     = null
  description = "Kubernetes minor version, such as 1.37. EKS chooses its current default when this is not set, and the cluster then stays on that version."
  type        = string

  validation {
    condition     = var.cluster_version == null || can(regex("^1\\.[0-9]+$", var.cluster_version))
    error_message = "The cluster version must be a Kubernetes minor version, such as 1.37."
  }
}

variable "endpoint_public_access_cidrs" {
  default     = ["0.0.0.0/0"]
  description = "CIDR blocks that can reach the public Kubernetes API endpoint. An empty list turns the public endpoint off, leaving the API reachable only from within the VPC."
  type        = set(string)

  validation {
    condition     = alltrue([for cidr in var.endpoint_public_access_cidrs : can(cidrhost(cidr, 0))])
    error_message = "Each entry must be a valid CIDR block, such as 203.0.113.0/24."
  }
}

variable "force_destroy" {
  default     = false
  description = "Delete the control plane logs with the cluster, and detach any policies added to the IAM roles outside this module so the roles can be deleted. Logs are kept when this is false."
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
  description = "Storage class of the control plane log group, either STANDARD or INFREQUENT_ACCESS."
  type        = string

  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.log_group_class)
    error_message = "The log group class must be STANDARD or INFREQUENT_ACCESS."
  }
}

variable "log_retention_in_days" {
  default     = 365
  description = "Days to keep control plane logs in CloudWatch Logs."
  type        = number
}

variable "node_pools" {
  default     = ["general-purpose", "system"]
  description = "Built-in EKS Auto Mode node pools to enable. Nodes are only launched for a pool once pods are scheduled to it."
  type        = set(string)

  validation {
    condition     = length(var.node_pools) > 0 && alltrue([for pool in var.node_pools : contains(["general-purpose", "system"], pool)])
    error_message = "At least one node pool is required, and each must be general-purpose or system."
  }
}

variable "subnet_ids" {
  description = "IDs of the subnets, in at least two Availability Zones, where EKS places the control plane network interfaces and Auto Mode launches nodes."
  type        = set(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "EKS needs subnets in at least two Availability Zones."
  }
}

variable "tags" {
  default     = {}
  description = "Tags to be applied to all applicable resources."
  type        = map(string)
}
