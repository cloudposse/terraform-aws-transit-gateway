locals {
  route_config_provided = var.route_table_ids != null && length(var.route_table_ids) > 0 && var.destination_cidr_blocks != null && length(var.destination_cidr_blocks) > 0
  route_config          = local.route_config_provided ? { for i in setproduct(var.route_table_ids, var.destination_cidr_blocks) : uuid() => i } : {}
}

resource "aws_route" "default" {
  for_each               = local.route_config
  transit_gateway_id     = var.transit_gateway_id
  provider               = var.provider_alias
  route_table_id         = each.value[0]
  destination_cidr_block = each.value[1]
}
