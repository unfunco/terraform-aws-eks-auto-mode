variable "create" {
  default     = true
  description = "Enable/disable the creation of all resources."
  type        = bool
}

variable "name" {
  description = "Name of the NodePool."
  type        = string
}

variable "node_class_name" {
  description = "Name of the NodeClass this pool should use."
  type        = string
}

variable "node_class_kind" {
  default     = "NodeClass"
  description = "Kind of the NodeClass resource."
  type        = string
}

variable "node_class_group" {
  default     = "eks.amazonaws.com"
  description = "API group of the NodeClass resource."
  type        = string
}

variable "annotations" {
  default     = {}
  description = "Annotations to apply to the NodePool template metadata."
  type        = map(string)
}

variable "labels" {
  default     = {}
  description = "Labels to apply to the NodePool template metadata."
  type        = map(string)
}

variable "requirements" {
  default     = []
  description = "Scheduling requirements for the NodePool (for example instance families, CPU, zones)."
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))

  validation {
    condition = alltrue([
      for requirement in var.requirements : contains(
        ["In", "NotIn", "Exists", "DoesNotExist", "Gt", "Lt"],
        requirement.operator,
      )
    ])
    error_message = "Each requirement.operator must be one of In, NotIn, Exists, DoesNotExist, Gt, or Lt."
  }
}

variable "taints" {
  default     = []
  description = "Taints to apply to nodes launched by this pool."
  type = list(object({
    key    = string
    value  = optional(string)
    effect = string
  }))

  validation {
    condition = alltrue([
      for taint in var.taints : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], taint.effect)
    ])
    error_message = "Each taint.effect must be one of NoSchedule, PreferNoSchedule, or NoExecute."
  }
}

variable "startup_taints" {
  default     = []
  description = "Taints that are set when the node starts up and removed after initialization."
  type = list(object({
    key    = string
    value  = optional(string)
    effect = string
  }))

  validation {
    condition = alltrue([
      for taint in var.startup_taints : contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], taint.effect)
    ])
    error_message = "Each startup taint.effect must be one of NoSchedule, PreferNoSchedule, or NoExecute."
  }
}

variable "expire_after" {
  default     = null
  description = "How long nodes should live before being rotated (for example 336h)."
  type        = string
}

variable "termination_grace_period" {
  default     = null
  description = "Grace period before terminating nodes (for example 24h)."
  type        = string
}

variable "disruption" {
  default     = null
  description = "Disruption settings controlling consolidation and budgets."
  type = object({
    budgets = optional(list(object({
      duration = optional(string)
      nodes    = optional(string)
    })))
    consolidate_after    = optional(string)
    consolidation_policy = optional(string)
  })

  validation {
    condition = var.disruption == null || var.disruption.consolidation_policy == null || contains(
      ["WhenEmpty", "WhenUnderutilized", "Never"],
      var.disruption.consolidation_policy,
    )
    error_message = "disruption.consolidation_policy must be one of WhenEmpty, WhenUnderutilized, or Never."
  }
}

variable "limits" {
  default     = null
  description = "Resource limits for the NodePool (for example cpu, memory)."
  type = object({
    cpu    = optional(string)
    memory = optional(string)
  })
}

variable "weight" {
  default     = null
  description = "Relative scheduling weight for this NodePool."
  type        = number
}
