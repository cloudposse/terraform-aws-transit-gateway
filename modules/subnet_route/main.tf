locals {
  route_config = {
    for i in setproduct(var.route_table_ids, var.destination_cidr_blocks) : "${i[0]}-${i[1]}" => i
  }
}

resource "aws_route" "default" {
  for_each               = local.route_config
  transit_gateway_id     = var.transit_gateway_id
  provider               = var.provider
  route_table_id         = each.value[0]
  destination_cidr_block = each.value[1]
}
