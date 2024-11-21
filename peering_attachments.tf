locals {
  tgw_peering_attachments = { for k, v in var.config : k => v if v.peering_peer_account_id != null }
}

resource "aws_ec2_transit_gateway_peering_attachment" "default" {
  for_each = module.this.enabled && var.create_transit_gateway_vpc_attachment && local.tgw_peering_attachments ? local.tgw_peering_attachments : {}

  transit_gateway_id      = local.transit_gateway_id
  peer_account_id         = each.value["peering_peer_account_id"]
  peer_region             = each.value["peering_peer_region"]
  peer_transit_gateway_id = each.value["peering_peer_transit_gateway_id"]
  tags                    = module.this.tags

  options {
    dynamic_routing = each.value["peering_enable_dynamic_routing"]
  }
}

# Allow traffic from the VPC attachments to the Transit Gateway
resource "aws_ec2_transit_gateway_route_table_association" "peering_attachment" {
  for_each                       = module.this.enabled && var.create_transit_gateway_route_table_association_and_propagation && local.tgw_peering_attachments != null ? local.tgw_peering_attachments : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_peering_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "peering_attachment" {
  for_each                       = module.this.enabled && var.create_transit_gateway_route_table_association_and_propagation && local.tgw_peering_attachments != null ? local.tgw_peering_attachments : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_peering_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
}

# Static Transit Gateway routes
# Static routes have a higher precedence than propagated routes
# https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
module "transit_gateway_route_peering_attachment" {
  source                         = "./modules/transit_gateway_route"
  for_each                       = module.this.enabled && var.create_transit_gateway_route_table_association_and_propagation && local.tgw_peering_attachments != null ? local.tgw_peering_attachments : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_peering_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_route_table_id
  route_config                   = each.value["static_routes"] != null ? each.value["static_routes"] : []

  depends_on = [aws_ec2_transit_gateway_peering_attachment.default, aws_ec2_transit_gateway_route_table.default]
}

# Create routes in the subnets' route tables to route traffic from subnets to the Transit Gateway VPC attachments
# Only route to VPCs of the environments defined in `route_to` attribute
module "subnet_route_peering_attachment" {
  source                  = "./modules/subnet_route"
  for_each                = module.this.enabled && var.create_transit_gateway_vpc_attachment && local.tgw_peering_attachments != null ? local.tgw_peering_attachments : {}
  transit_gateway_id      = local.transit_gateway_id
  route_table_ids         = each.value["subnet_route_table_ids"] != null ? each.value["subnet_route_table_ids"] : []
  destination_cidr_blocks = each.value["route_to_cidr_blocks"] != null ? each.value["route_to_cidr_blocks"] : ([for i in setintersection(keys(local.tgw_peering_attachments), (each.value["route_to"] != null ? each.value["route_to"] : [])) : local.tgw_peering_attachments[i]["vpc_cidr"]])
  route_keys_enabled      = var.route_keys_enabled
  route_timeouts          = var.route_timeouts

  depends_on = [aws_ec2_transit_gateway.default, data.aws_ec2_transit_gateway.this, aws_ec2_transit_gateway_peering_attachment.default]
}
