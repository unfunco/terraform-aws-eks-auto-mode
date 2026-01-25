// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

variable "advanced_networking" {
  default     = null
  description = "Advanced networking configuration."
  type = object({
    associatePublicIPAddress = optional(bool)
    httpsProxy               = optional(string)
    noProxy                  = optional(list(string))
  })
}

variable "advanced_security" {
  default     = null
  description = "Advanced security configuration."
  type = object({
    fips = optional(bool)
  })
}

variable "certificate_bundles" {
  default     = null
  description = "Base64-encoded custom certificate bundles."
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "create" {
  default     = true
  description = "Enable/disable the creation of all resources."
  type        = bool
}

variable "ephemeral_storage" {
  default     = null
  description = "Ephemeral storage configuration."
  type = object({
    iops       = optional(number)
    kmsKeyID   = optional(string)
    size       = optional(string)
    throughput = optional(number)
  })
}

variable "instance_profile" {
  default     = null
  description = "Instance profile name for EC2 instances. Mutually exclusive with role."
  type        = string
}

variable "name" {
  description = "Name of the NodeClass."
  type        = string
}

variable "network_policy" {
  default     = null
  description = "Network policy for the NodeClass. Valid values: DefaultAllow, DefaultDeny."
  type        = string

  validation {
    condition     = var.network_policy == null || contains(["DefaultAllow", "DefaultDeny"], var.network_policy)
    error_message = "network_policy must be either 'DefaultAllow' or 'DefaultDeny'."
  }
}

variable "pod_security_group_selector_terms" {
  default     = null
  description = "Pod security group selector terms."
  type = list(object({
    id   = optional(string)
    name = optional(string)
    tags = optional(map(string))
  }))
}

variable "pod_subnet_selector_terms" {
  default     = null
  description = "Pod subnet selector terms."
  type = list(object({
    id   = optional(string)
    tags = optional(map(string))
  }))
}

variable "role" {
  default     = null
  description = "IAM role ARN for EC2 instances. Mutually exclusive with instance_profile."
  type        = string

  validation {
    condition     = var.role == null || startswith(var.role, "arn:aws:iam::")
    error_message = "role must be a valid IAM role ARN."
  }
}

variable "security_group_selector_terms" {
  description = "List of security group selector terms with tags, ID, or name."
  type = list(object({
    id   = optional(string)
    name = optional(string)
    tags = optional(map(string))
  }))
}

variable "snat_policy" {
  default     = null
  description = "SNAT policy for the NodeClass. Valid values: Random, Disabled."
  type        = string

  validation {
    condition     = var.snat_policy == null || contains(["Random", "Disabled"], var.snat_policy)
    error_message = "snat_policy must be either 'Random' or 'Disabled'."
  }
}

variable "subnet_selector_terms" {
  description = "List of subnet selector terms with tags or ID."
  type = list(object({
    id   = optional(string)
    tags = optional(map(string))
  }))
}

variable "tags" {
  default     = {}
  description = "Custom EC2 tags to apply to instances."
  type        = map(string)
}
