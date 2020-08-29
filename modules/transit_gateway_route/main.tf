locals {
  route_config_map = { for v in var.route_config : uuid() => v }
}

resource "aws_ec2_transit_gateway_route" "default" {
  for_each                       = local.route_config_map
  blackhole                      = each.value["blackhole"]
  destination_cidr_block         = each.value["destination_cidr_block"]
  transit_gateway_attachment_id  = var.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
