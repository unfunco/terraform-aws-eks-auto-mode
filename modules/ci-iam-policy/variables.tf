// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

variable "cluster_name" {
  description = "Name of the EKS cluster the pipeline deploys, as passed to the root module."
  type        = string
}

variable "kms_key_arns" {
  default     = []
  description = "ARNs of the KMS keys passed to the root module, which the pipeline must be able to describe and create grants on."
  type        = set(string)
}
