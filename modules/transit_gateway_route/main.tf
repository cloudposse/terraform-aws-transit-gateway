locals {
  route_config = { for rc in var.route_config : format("%v%v", rc.destination_cidr_block, rc.blackhole ? ":bh" : "") => rc }
}
resource "aws_ec2_transit_gateway_route" "default" {
  for_each                       = local.route_config
  blackhole                      = each.value["blackhole"]
  destination_cidr_block         = each.value["destination_cidr_block"]
  transit_gateway_attachment_id  = each.value["blackhole"] ? null : var.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
