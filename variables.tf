variable "ram_resource_share_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable sharing the Transit Gateway with the Organization using Resource Access Manager (RAM)"
}

variable "ram_principal" {
  type        = string
  default     = null
  description = <<-EOT
    DEPRECATED, please use ram_principals instead.

    The principal to associate with the resource share. Possible values are an
    AWS account ID, an Organization ARN, or an Organization Unit ARN.
  EOT
}

variable "ram_principals" {
  type        = list(string)
  default     = []
  description = <<-EOT
    A list of principals to associate with the resource share. Possible values
    are:

    * AWS account ID
    * Organization ARN
    * Organization Unit ARN

    If this (and var.ram_principal) is not provided and
    `ram_resource_share_enabled` is `true`, the Organization ARN will be used.
  EOT
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

variable "vpc_attachment_appliance_mode_support" {
  type        = string
  default     = "disable"
  description = "Whether Appliance Mode support is enabled. If enabled, a traffic flow between a source and destination uses the same Availability Zone for the VPC attachment for the lifetime of that flow. Valid values: `disable`, `enable`"
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
    vpc_id                            = string
    vpc_cidr                          = string
    subnet_ids                        = set(string)
    subnet_route_table_ids            = set(string)
    route_to                          = set(string)
    route_to_cidr_blocks              = set(string)
    transit_gateway_vpc_attachment_id = string
    attach_to_transit_route_table     = bool
    inspection_static_routes = set(object({
      blackhole              = bool
      destination_cidr_block = string
    }))
    transit_static_routes = set(object({
      blackhole              = bool
      destination_cidr_block = string
    }))
  }))

  description = <<-EOT
  Configuration for VPC attachments, Transit Gateway routes, and subnet routes
  Attribute `attach_to_transit_route_table` means this config will attach to global tgw-rt, otherwise will attach to inspection tgw-rt
  EOT
  default     = null
}

variable "existing_transit_gateway_id" {
  type        = string
  default     = null
  description = "Existing Transit Gateway ID. If provided, the module will not create a Transit Gateway but instead will use the existing one"
}

variable "existing_transit_gateway_inspection_route_table_id" {
  type        = string
  default     = null
  description = "Existing Transit Gateway Inspection Route Table ID. If provided, the module will not create a Transit Gateway Route Table but instead will use the existing one"
}

variable "existing_transit_gateway_transit_route_table_id" {
  type        = string
  default     = null
  description = "Existing Transit Gateway Transit Route Table ID. If provided, the module will not create a Transit Gateway Route Table but instead will use the existing one"
}

variable "create_transit_gateway" {
  type        = bool
  default     = true
  description = "Whether to create a Transit Gateway. If set to `false`, an existing Transit Gateway ID must be provided in the variable `existing_transit_gateway_id`"
}

variable "create_transit_gateway_route_table" {
  type        = bool
  default     = true
  description = "Whether to create a Transit Gateway Route Table. If set to `false`, an existing Transit Gateway Route Table ID must be provided in the variable `existing_transit_gateway_route_table_id`"
}

variable "create_transit_gateway_vpc_attachment" {
  type        = bool
  default     = true
  description = "Whether to create Transit Gateway VPC Attachments"
}

variable "create_transit_gateway_inspection_route_table_association" {
  type        = bool
  default     = true
  description = "Whether to create Transit Gateway Route Table associations"
}

variable "create_transit_gateway_inspection_route_table_propagation" {
  type        = bool
  default     = true
  description = "Whether to create Transit Gateway Route Table propagations"
}

variable "create_transit_gateway_inspection_route_table_static_route" {
  type        = bool
  default     = true
  description = "Whether to create custom static route in Transit Gateway Route Table"
}

variable "create_transit_gateway_transit_route_table_association" {
  type        = bool
  default     = true
  description = "Whether to create Additiontal Transit Gateway Route Table associations"
}

variable "create_transit_gateway_transit_route_table_propagation" {
  type        = bool
  default     = true
  description = "Whether to create Additiontal Transit Gateway Route Table propagations"
}

variable "create_transit_gateway_transit_route_table_static_route" {
  type        = bool
  default     = true
  description = "Whether to create custom static route in Transit Gateway Global Route Table"
}

variable "route_keys_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    If true, Terraform will use keys to label routes, preventing unnecessary changes,
    but this requires that the VPCs and subnets already exist before using this module.
    If false, Terraform will use numbers to label routes, and a single change may
    cascade to a long list of changes because the index or order has changed, but
    this will work when the `true` setting generates the error `The "for_each" value depends on resource attributes...`
    EOT
}

variable "transit_gateway_cidr_blocks" {
  type        = list(string)
  default     = null
  description = <<-EOT
    The list of associated CIDR blocks. It can contain up to 1 IPv4 CIDR block
    of size up to /24 and up to one IPv6 CIDR block of size up to /64. The IPv4
    block must not be from range 169.254.0.0/16.
  EOT
}

variable "transit_gateway_description" {
  type        = string
  default     = ""
  description = "Transit Gateway description. If not provided, one will be automatically generated."
}

variable "transit_gateway_inspection_route_table_name_override" {
  type        = string
  default     = null
  description = "Transit Gateway name override. If not provided, same name as Transit Gateway will be used."
}

variable "transit_gateway_transit_route_table_name_override" {
  type        = string
  default     = null
  description = "Add an additional Transit Gateway, and value will be the name of this tgw."
}

variable "subnet_route_to_transit_gateway" {
  type = map(object({
    subnet_route_table_ids = set(string)
    cidr_blocks            = set(string)
  }))

  description = "Block for adding routes to the selected subenets to this Transit Gateway"
  default     = null
}

variable "amazon_side_asn" {
  type        = number
  default     = 64512
  description = <<-EOT
    Private Autonomous System Number (ASN) for the Amazon side of a BGP session. 
    The range is 64512 to 65534 for 16-bit ASNs and 4200000000 to 4294967294 for 32-bit ASNs. 
    Default value: 64512
  EOT
  validation {
    condition = (
      var.amazon_side_asn >= 64512 &&
      var.amazon_side_asn <= 65534
    )
    error_message = "ASN must be between 64512 and 65534."
  }
}

variable "create_transit_gateway_peering_attachment" {
  type        = bool
  default     = false
  description = "Whether to create Transit Gateway Peering Attachments"
}

variable "transit_gateway_peering_attachment_config" {
  type = map(object({
    peer_account_id         = number
    peer_region             = string
    peer_transit_gateway_id = string
  }))

  description = "Config for creat TGW peering attachment"
  default     = null
}

variable "create_transit_gateway_peering_attachment_accepter" {
  type        = bool
  default     = false
  description = "Whether to create Transit Gateway Peering Attachments Accepter"
}

variable "transit_gateway_peering_attachment_accepter_config" {
  type = map(object({
    transit_gateway_attachment_id = string
  }))

  description = "Config for creat TGW peering attachment accepter"
  default     = null
}