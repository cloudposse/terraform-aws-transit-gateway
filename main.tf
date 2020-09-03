locals {
  transit_gateway_id             = var.existing_transit_gateway_id != null && var.existing_transit_gateway_id != "" ? var.existing_transit_gateway_id : try(aws_ec2_transit_gateway.default[0].id, "")
  transit_gateway_route_table_id = var.existing_transit_gateway_route_table_id != null && var.existing_transit_gateway_route_table_id != "" ? var.existing_transit_gateway_route_table_id : try(aws_ec2_transit_gateway_route_table.default[0].id, "")
}

resource "aws_ec2_transit_gateway" "default" {
  count                           = var.existing_transit_gateway_id == null ? 1 : 0
  description                     = format("%s Transit Gateway", module.this.id)
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  tags                            = module.this.tags
}

resource "aws_ec2_transit_gateway_route_table" "default" {
  count              = var.existing_transit_gateway_route_table_id == null ? 1 : 0
  transit_gateway_id = local.transit_gateway_id
  tags               = module.this.tags
}

resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  for_each                                        = var.config != null ? var.config : {}
  transit_gateway_id                              = local.transit_gateway_id
  vpc_id                                          = each.value["vpc_id"]
  subnet_ids                                      = each.value["subnet_ids"]
  dns_support                                     = var.vpc_attachment_dns_support
  ipv6_support                                    = var.vpc_attachment_ipv6_support
  tags                                            = module.this.tags
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

# Allow traffic from the VPC attachments to the Transit Gateway
resource "aws_ec2_transit_gateway_route_table_association" "default" {
  for_each                       = var.config != null ? var.config : {}
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "default" {
  for_each                       = var.config != null ? var.config : {}
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}

# Static Transit Gateway routes
# Static routes have a higher precedence than propagated routes
# https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
module "transit_gateway_route" {
  source                         = "./modules/transit_gateway_route"
  for_each                       = var.config != null ? var.config : {}
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
  route_config                   = each.value["static_routes"] != null ? each.value["static_routes"] : []
}

# Create routes in the subnets' route tables to route traffic from subnets to the Transit Gateway VPC attachments
# Only route to VPCs of the environments defined in `route_to` attribute
module "subnet_route" {
  source                  = "./modules/subnet_route"
  for_each                = var.config != null ? var.config : {}
  transit_gateway_id      = local.transit_gateway_id
  route_table_ids         = each.value["subnet_route_table_ids"] != null ? each.value["subnet_route_table_ids"] : []
  destination_cidr_blocks = each.value["route_to_cidr_blocks"] != null ? each.value["route_to_cidr_blocks"] : ([for i in setintersection(keys(var.config), (each.value["route_to"] != null ? each.value["route_to"] : [])) : var.config[i]["vpc_cidr"]])
}
