locals {
  enabled       = module.this.enabled
  enabled_count = local.enabled ? 1 : 0
  config        = local.enabled ? var.config : {}
  config_keys   = keys(local.config)
}

resource "aws_ec2_transit_gateway" "default" {
  count                           = local.enabled_count
  description                     = format("%s Transit Gateway", module.this.id)
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  tags                            = module.this.tags
}

resource "aws_ec2_transit_gateway_route_table" "default" {
  count              = local.enabled_count
  transit_gateway_id = try(aws_ec2_transit_gateway.default[0].id, "")
  tags               = module.this.tags
}

# RAM share for Transit Gateway
resource "aws_ram_resource_share" "default" {
  count                     = local.enabled_count
  name                      = module.this.id
  allow_external_principals = var.allow_external_principals
  tags                      = module.this.tags
}

# Share the Transit Gateway with the Organization
data "aws_organizations_organization" "default" {}

resource "aws_ram_resource_association" "default" {
  count              = local.enabled_count
  resource_arn       = try(aws_ec2_transit_gateway.default[0].arn, "")
  resource_share_arn = try(aws_ram_resource_share.default[0].id, "")
}

resource "aws_ram_principal_association" "default" {
  count              = local.enabled_count
  principal          = data.aws_organizations_organization.default.arn
  resource_share_arn = try(aws_ram_resource_share.default[0].id, "")
}

resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  for_each                                        = local.config
  transit_gateway_id                              = try(aws_ec2_transit_gateway.default[0].id, "")
  provider                                        = each.value["provider"]
  vpc_id                                          = each.value["vpc_id"]
  subnet_ids                                      = each.value["subnet_ids"]
  dns_support                                     = var.vpc_attachment_dns_support
  ipv6_support                                    = var.vpc_attachment_ipv6_support
  tags                                            = module.this.tags
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

# Allow traffic from the VPC attachments to the Transit Gateway
# You can associate a Transit Gateway attachment with a single route table
resource "aws_ec2_transit_gateway_route_table_association" "default" {
  for_each                       = local.config
  transit_gateway_attachment_id  = try(aws_ec2_transit_gateway_vpc_attachment.default[each.key], "")
  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.default[0].id, "")
}

# Allow traffic from the Transit Gateway to the VPC attachments. Propagations will create propagated routes to the VPC attachments
# You can create a propagation of Transit Gateway attachment with multiple route tables
resource "aws_ec2_transit_gateway_route_table_propagation" "default" {
  for_each                       = local.config
  transit_gateway_attachment_id  = try(aws_ec2_transit_gateway_vpc_attachment.default[each.key], "")
  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.default[0].id, "")
}

# Static TG routes
resource "aws_ec2_transit_gateway_route" "default" {
  for_each                       = { for c in setproduct(local.config_keys, var.route_to_accounts) : "${c[0]}-${c[1]}" => c }
  blackhole                      = each.value["blackhole"]
  destination_cidr_block         = each.value["destination_cidr_block"]
  transit_gateway_attachment_id  = try(aws_ec2_transit_gateway_vpc_attachment.default[each.key], "")
  transit_gateway_route_table_id = try(aws_ec2_transit_gateway_route_table.default[0].id, "")
}

# Subnet routes. Create routes from subnets to the Transit Gateway VPC attachments
resource "aws_route" "default" {
  for_each               = local.route_config
  transit_gateway_id     = try(aws_ec2_transit_gateway.default[0].id, "")
  route_table_id         = each.value[0]
  destination_cidr_block = ""
}
