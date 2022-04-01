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

data "aws_vpc" "default" {
  for_each = module.this.enabled && var.create_transit_gateway_vpc_attachment && var.config != null ? var.config : {}
  id       = each.value["vpc_id"]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  for_each               = module.this.enabled && var.create_transit_gateway_vpc_attachment && var.config != null ? var.config : {}
  transit_gateway_id     = local.transit_gateway_id
  vpc_id                 = each.value["vpc_id"]
  subnet_ids             = each.value["subnet_ids"]
  appliance_mode_support = var.vpc_attachment_appliance_mode_support
  dns_support            = var.vpc_attachment_dns_support
  ipv6_support           = var.vpc_attachment_ipv6_support
  tags                   = module.this.tags

  # transit_gateway_default_route_table_association and transit_gateway_default_route_table_propagation
  # must be set to `false` if the VPC is in the same account as the Transit Gateway, and `null` otherwise
  # https://github.com/terraform-providers/terraform-provider-aws/issues/13512
  # https://github.com/terraform-providers/terraform-provider-aws/issues/8383
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment
  transit_gateway_default_route_table_association = data.aws_ec2_transit_gateway.this[0].owner_id == data.aws_vpc.default[each.key].owner_id ? false : null
  transit_gateway_default_route_table_propagation = data.aws_ec2_transit_gateway.this[0].owner_id == data.aws_vpc.default[each.key].owner_id ? false : null
}

# Allow traffic from the VPC attachments to the Transit Gateway
resource "aws_ec2_transit_gateway_route_table_association" "default" {
  for_each                       = module.this.enabled && var.create_transit_gateway_route_table_association_and_propagation && var.config != null ? var.config : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "default" {
  for_each                       = module.this.enabled && var.create_transit_gateway_route_table_association_and_propagation && var.config != null ? var.config : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}

# Static Transit Gateway routes
# Static routes have a higher precedence than propagated routes
# https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
module "transit_gateway_route" {
  source                         = "./modules/transit_gateway_route"
  for_each                       = module.this.enabled && var.create_transit_gateway_route_table_association_and_propagation && var.config != null ? var.config : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
  route_config                   = each.value["static_routes"] != null ? each.value["static_routes"] : []

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.default, aws_ec2_transit_gateway_route_table.default]
}

# Create routes in the subnets' route tables to route traffic from subnets to the Transit Gateway VPC attachments
# Only route to VPCs of the environments defined in `route_to` attribute
module "subnet_route" {
  source                  = "./modules/subnet_route"
  for_each                = module.this.enabled && var.create_transit_gateway_vpc_attachment && var.config != null ? var.config : {}
  transit_gateway_id      = local.transit_gateway_id
  route_table_ids         = each.value["subnet_route_table_ids"] != null ? each.value["subnet_route_table_ids"] : []
  destination_cidr_blocks = each.value["route_to_cidr_blocks"] != null ? each.value["route_to_cidr_blocks"] : ([for i in setintersection(keys(var.config), (each.value["route_to"] != null ? each.value["route_to"] : [])) : var.config[i]["vpc_cidr"]])
  route_keys_enabled      = var.route_keys_enabled

  depends_on = [aws_ec2_transit_gateway.default, data.aws_ec2_transit_gateway.this, aws_ec2_transit_gateway_vpc_attachment.default]
}
