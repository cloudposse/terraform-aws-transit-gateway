resource "aws_route" "default" {
  for_each               = var.route_table_ids
  transit_gateway_id     = var.transit_gateway_id
  route_table_id         = each.value
  destination_cidr_block = var.destination_cidr_block
}
