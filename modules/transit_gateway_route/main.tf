resource "aws_ec2_transit_gateway_route" "default" {
  count                          = length(var.route_config)
  blackhole                      = var.route_config[count.index]["blackhole"]
  destination_cidr_block         = var.route_config[count.index]["destination_cidr_block"]
  transit_gateway_attachment_id  = var.transit_gateway_attachment_id
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
}
