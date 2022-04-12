locals {
  transit_gateway_transit_route_table_id = var.existing_transit_gateway_route_table_id != null && var.existing_transit_gateway_route_table_id != "" ? var.existing_transit_gateway_route_table_id : (
    module.this.enabled && var.create_transit_gateway_route_table && var.transit_gateway_transit_route_table_name_override != null ? aws_ec2_transit_gateway_route_table.transit[0].id : null
  )
}

resource "aws_ec2_transit_gateway_route_table" "transit" {
  count              = module.this.enabled && var.create_transit_gateway_route_table && var.transit_gateway_transit_route_table_name_override != null ? 1 : 0
  transit_gateway_id = local.transit_gateway_id
  tags = merge(
    module.this.tags,
    {
      "Name" = "${var.transit_gateway_transit_route_table_name_override}"
    },
  )
}

# Allow traffic from the VPC attachments to the Transit Gateway
resource "aws_ec2_transit_gateway_route_table_association" "transit" {
  for_each                       = module.this.enabled && var.create_transit_gateway_transit_route_table_association && var.config != null ? { for k, v in var.config : k => v if v.attach_to_transit_route_table } : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_transit_route_table_id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "transit" {
  for_each                       = module.this.enabled && var.create_transit_gateway_transit_route_table_propagation && var.config != null ? { for k, v in var.config : k => v if v.attach_to_transit_route_table } : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_transit_route_table_id
}

# Static Transit Gateway routes
# Static routes have a higher precedence than propagated routes
# https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
module "transit_gateway_route_transit" {
  source                         = "./modules/transit_gateway_route"
  for_each                       = module.this.enabled && var.create_transit_gateway_transit_route_table_static_route && var.config != null ? var.config : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.transit_gateway_transit_route_table_id
  route_config                   = each.value["transit_static_routes"] != null ? each.value["transit_static_routes"] : []

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.default, aws_ec2_transit_gateway_route_table.transit]
}

# Create routes in the subnets' route tables to route traffic from subnets to the Transit Gateway VPC attachments
# Only route to VPCs of the environments defined in `route_to` attribute
module "subnet_route_transit" {
  source                  = "./modules/subnet_route"
  for_each                = module.this.enabled && var.create_transit_gateway_vpc_attachment && var.config != null ? { for k, v in var.config : k => v if v.attach_to_transit_route_table } : {}
  transit_gateway_id      = local.transit_gateway_id
  route_table_ids         = each.value["subnet_route_table_ids"] != null ? each.value["subnet_route_table_ids"] : []
  destination_cidr_blocks = each.value["route_to_cidr_blocks"] != null ? each.value["route_to_cidr_blocks"] : ([for i in setintersection(keys(var.config), (each.value["route_to"] != null ? each.value["route_to"] : [])) : var.config[i]["vpc_cidr"]])
  route_keys_enabled      = var.route_keys_enabled

  depends_on = [aws_ec2_transit_gateway.default, data.aws_ec2_transit_gateway.this, aws_ec2_transit_gateway_vpc_attachment.default]
}
