variable "region" {
  type        = string
  description = "AWS Region"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "ram_resource_share_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable sharing the Transit Gateway with the Organization using Resource Access Manager (RAM)"
}

variable "ram_principal" {
  type        = string
  default     = null
  description = "The principal to associate with the resource share. Possible values are an AWS account ID, an Organization ARN, or an Organization Unit ARN. If this is not provided and `ram_resource_share_enabled` is set to `true`, the Organization ARN will be used"
}

variable "auto_accept_shared_attachments" {
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

variable "dns_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "vpn_ecmp_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "allow_external_principals" {
  type        = bool
  default     = false
  description = "Indicates whether principals outside your organization can be associated with a resource share"
}

variable "vpc_attachment_dns_support" {
  type        = string
  default     = "enable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}

variable "vpc_attachment_ipv6_support" {
  type        = string
  default     = "disable"
  description = "Whether resource attachments automatically propagate routes to the default propagation route table. Valid values: `disable`, `enable`. Default value: `enable`"
}
