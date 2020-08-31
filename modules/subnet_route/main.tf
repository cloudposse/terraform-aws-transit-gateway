locals {
  route_config_provided = var.route_table_ids != null && length(var.route_table_ids) > 0 && var.destination_cidr_blocks != null && length(var.destination_cidr_blocks) > 0
  route_config          = local.route_config_provided ? [for i in setproduct(var.route_table_ids, var.destination_cidr_blocks) : i] : []
}

resource "aws_route" "default" {
  count                  = length(local.route_config)
  transit_gateway_id     = var.transit_gateway_id
  route_table_id         = local.route_config[count.index][0]
  destination_cidr_block = local.route_config[count.index][1]
}
