variable "auto_accept" {
  type        = string
  default     = "enable"
  description = "Whether resource attachment requests are automatically accepted. Valid values: `disable`, `enable`. Default value: `disable`"
}

variable "default_route_table_association" {
  type        = string
  default     = "disable"
  description = "Whether resource attachments are automatically associated with the default association route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "default_route_table_propagation" {
  type        = string
  default     = "disable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "add_blackhole_route" {
  type        = bool
  default     = true
  description = "Whether or not to add a blackhole route for 0.0.0.0/0 to the Transit Gateway, default is `true`"
}

variable "allow_external_principals" {
  type        = bool
  default     = false
  description = "Indicates whether principals outside your organization can be associated with a resource share"
}
variable "allowed_principles" {
  type        = list(string)
  default     = []
  description = "List of principals allowed to access this share, can be account IDs or Organization ARNs"
}
