variable "create" {
  default     = true
  description = "Enable/disable the creation of all resources."
  type        = bool
}

variable "tags" {
  default     = {}
  description = "Tags to be applied to all applicable resources."
  type        = map(string)
}
