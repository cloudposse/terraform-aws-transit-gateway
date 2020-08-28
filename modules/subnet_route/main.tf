locals {
  route_config = {
    for config in setproduct(var.route_table_ids, var.destination_cidr_blocks) : "${config[0]}-${config[1]}" => config
  }
}

resource "aws_route" "default" {
  for_each               = local.route_config
  transit_gateway_id     = var.transit_gateway_id
  provider               = var.provider
  route_table_id         = each.value[0]
  destination_cidr_block = each.value[1]
}
