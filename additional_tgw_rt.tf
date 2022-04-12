locals {
  addtional_transit_gateway_route_table_id = var.existing_transit_gateway_route_table_id != null && var.existing_transit_gateway_route_table_id != "" ? var.existing_transit_gateway_route_table_id : (
    module.this.enabled && var.create_transit_gateway_route_table && var.addtional_transit_gateway_route_table != null ? aws_ec2_transit_gateway_route_table.addtional[0].id : null
  )
}

resource "aws_ec2_transit_gateway_route_table" "addtional" {
  count              = module.this.enabled && var.create_transit_gateway_route_table && var.addtional_transit_gateway_route_table != null ? 1 : 0
  transit_gateway_id = local.transit_gateway_id
  tags = merge(
    module.this.tags,
    {
      "Name" = "${var.addtional_transit_gateway_route_table}"
    },
  )
}

# Allow traffic from the VPC attachments to the Transit Gateway
resource "aws_ec2_transit_gateway_route_table_association" "addtional" {
  for_each                       = module.this.enabled && var.create_additional_transit_gateway_route_table_association_and_propagation && var.config != null ? { for k, v in var.config : k => v if v.attach_to_additional_only } : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.addtional_transit_gateway_route_table_id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "addtional" {
  for_each                       = module.this.enabled && var.create_additional_transit_gateway_route_table_association_and_propagation && var.config != null ? { for k, v in var.config : k => v if v.attach_to_additional_only } : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.addtional_transit_gateway_route_table_id
}

# Static Transit Gateway routes
# Static routes have a higher precedence than propagated routes
# https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
module "transit_gateway_route_additional" {
  source                         = "./modules/transit_gateway_route"
  for_each                       = module.this.enabled && var.create_additional_transit_gateway_route_table_association_and_propagation && var.config != null ? { for k, v in var.config : k => v if v.attach_to_additional_only } : {}
  transit_gateway_attachment_id  = each.value["transit_gateway_vpc_attachment_id"] != null ? each.value["transit_gateway_vpc_attachment_id"] : aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = local.addtional_transit_gateway_route_table_id
  route_config                   = each.value["static_routes"] != null ? each.value["static_routes"] : []

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.default, aws_ec2_transit_gateway_route_table.addtional]
}

# Create routes in the subnets' route tables to route traffic from subnets to the Transit Gateway VPC attachments
# Only route to VPCs of the environments defined in `route_to` attribute
module "subnet_route_additional" {
  source                  = "./modules/subnet_route"
  for_each                = module.this.enabled && var.create_transit_gateway_vpc_attachment && var.config != null ? { for k, v in var.config : k => v if v.attach_to_additional_only } : {}
  transit_gateway_id      = local.transit_gateway_id
  route_table_ids         = each.value["subnet_route_table_ids"] != null ? each.value["subnet_route_table_ids"] : []
  destination_cidr_blocks = each.value["route_to_cidr_blocks"] != null ? each.value["route_to_cidr_blocks"] : ([for i in setintersection(keys(var.config), (each.value["route_to"] != null ? each.value["route_to"] : [])) : var.config[i]["vpc_cidr"]])
  route_keys_enabled      = var.route_keys_enabled

  depends_on = [aws_ec2_transit_gateway.default, data.aws_ec2_transit_gateway.this, aws_ec2_transit_gateway_vpc_attachment.default]
}
