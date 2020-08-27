locals {
  enabled_count = var.enabled ? 1 : 0
}

module "base_label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.19.0"
  namespace   = var.namespace
  name        = var.name
  stage       = var.stage
  environment = var.environment
  delimiter   = var.delimiter
  attributes  = var.attributes
  tags        = var.tags
  enabled     = var.enabled
}

module "tgw_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.19.0"
  context    = module.base_label.context
  attributes = distinct(compact(concat(module.base_label.attributes, ["tgw"])))
}

resource "aws_ec2_transit_gateway" "default" {
  count                           = local.enabled_count
  description                     = "AWS Transit Gateway"
  auto_accept_shared_attachments  = var.auto_accept
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  tags                            = module.tgw_label.tags
}

# Add a Blackhole route to the transit gateway
resource "aws_ec2_transit_gateway_route" "tgw_blackhole_route" {
  count                          = var.add_blackhole_route && var.enabled ? 1 : 0
  destination_cidr_block         = "0.0.0.0/0"
  blackhole                      = true
  transit_gateway_route_table_id = join("", aws_ec2_transit_gateway.default.*.association_default_route_table_id)
}

# Setup RAM for transit Gateway
module "ram_label" {
  source  = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  context = module.base_label.context
  attributes = distinct(compact(concat(module.base_label.attributes, [
  "ram"])))
}

resource "aws_ram_resource_share" "tgw_ram_share" {
  count                     = local.enabled_count
  name                      = "example"
  allow_external_principals = var.allow_external_principles
  tags                      = module.ram_label.tags
}
