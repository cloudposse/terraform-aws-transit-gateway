variable "ram_resource_share_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable sharing the Transit Gateway with the Organization using Resource Access Manager (RAM)"
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

variable "config" {
  type = map(object({
    provider               = string
    vpc_id                 = string
    vpc_cidr               = string
    subnet_ids             = set(string)
    subnet_route_table_ids = set(string)
    static_routes = set(object({
      blackhole              = bool
      destination_cidr_block = string
    }))
    route_to = set(string)
  }))

  description = "Configuration for Transit Gateway, VPC attachments, Transit Gateway routes, and subnet routes"
}
