locals {
  route_config_provided = var.route_table_ids != null && length(var.route_table_ids) > 0 && var.destination_cidr_blocks != null && length(var.destination_cidr_blocks) > 0
  route_config_list     = local.route_config_provided ? [for i in setproduct(var.route_table_ids, var.destination_cidr_blocks) : i] : []
  route_config_map      = local.route_config_provided ? { for i in local.route_config_list : format("%v:%v", i[0], i[1]) => i } : {}
}

resource "aws_route" "keys" {
  for_each               = var.route_keys_enabled ? local.route_config_map : {}
  transit_gateway_id     = var.transit_gateway_id
  route_table_id         = each.value[0]
  destination_cidr_block = each.value[1]

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "count" {
  count                  = var.route_keys_enabled ? 0 : length(local.route_config_list)
  transit_gateway_id     = var.transit_gateway_id
  route_table_id         = local.route_config_list[count.index][0]
  destination_cidr_block = local.route_config_list[count.index][1]

  timeouts {
    create = "5m"
  }
}
