locals {
  transit_gateway_id = var.existing_transit_gateway_id != null && var.existing_transit_gateway_id != "" ? var.existing_transit_gateway_id : (
    module.this.enabled && var.create_transit_gateway ? aws_ec2_transit_gateway.default[0].id : null
  )
  transit_gateway_route_table_id = var.existing_transit_gateway_route_table_id != null && var.existing_transit_gateway_route_table_id != "" ? var.existing_transit_gateway_route_table_id : (
    module.this.enabled && var.create_transit_gateway_route_table ? aws_ec2_transit_gateway_route_table.default[0].id : null
  )
  # NOTE: This is the same logic as local.transit_gateway_id but we cannot reuse that local in the data source or
  # we get the dreaded error: "count" value depends on resource attributes
  lookup_transit_gateway = module.this.enabled && ((var.existing_transit_gateway_id != null && var.existing_transit_gateway_id != "") || var.create_transit_gateway)
}

resource "aws_ec2_transit_gateway" "default" {
  count                           = module.this.enabled && var.create_transit_gateway ? 1 : 0
  description                     = var.transit_gateway_description == "" ? format("%s Transit Gateway", module.this.id) : var.transit_gateway_description
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  tags                            = module.this.tags
  transit_gateway_cidr_blocks     = var.transit_gateway_cidr_blocks
}

resource "aws_ec2_transit_gateway_route_table" "default" {
  count              = module.this.enabled && var.create_transit_gateway_route_table ? 1 : 0
  transit_gateway_id = local.transit_gateway_id
  tags               = module.this.tags
}

# Need to find out if VPC is in same account as Transit Gateway.
# See resource "aws_ec2_transit_gateway_vpc_attachment" below.
data "aws_ec2_transit_gateway" "this" {
  count = local.lookup_transit_gateway ? 1 : 0
  id    = local.transit_gateway_id
}
