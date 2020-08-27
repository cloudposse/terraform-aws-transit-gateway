locals {
  enabled_count = module.this.enabled ? 1 : 0
}

resource "aws_ec2_transit_gateway" "default" {
  count                           = local.enabled_count
  description                     = "${module.this.id} Transit Gateway"
  auto_accept_shared_attachments  = var.auto_accept
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags                            = module.this.tags
}

# https://www.terraform.io/docs/providers/aws/r/ec2_transit_gateway_route_table.html
resource "aws_ec2_transit_gateway_route_table" "default" {
  count              = local.enabled_count
  transit_gateway_id = join("", aws_ec2_transit_gateway.default.*.id)
  tags               = module.this.tags
}

# Add a Blackhole route to the transit gateway
resource "aws_ec2_transit_gateway_route" "tgw_blackhole_route" {
  count                          = var.add_blackhole_route ? local.enabled_count : 0
  destination_cidr_block         = "0.0.0.0/0"
  blackhole                      = true
  transit_gateway_route_table_id = join("", aws_ec2_transit_gateway_route_table.default.*.id)
}

# RAM share for transit Gateway
resource "aws_ram_resource_share" "default" {
  count                     = local.enabled_count
  name                      = module.this.id
  allow_external_principals = var.allow_external_principals
  tags                      = module.this.tags
}

# Share the Transit Gateway with the Organization
# https://www.terraform.io/docs/providers/aws/d/organizations_organization.html
data "aws_organizations_organization" "default" {}

# https://www.terraform.io/docs/providers/aws/r/ram_resource_association.html
resource "aws_ram_resource_association" "default" {
  count              = local.enabled_count
  resource_arn       = join("", aws_ec2_transit_gateway.default.*.arn)
  resource_share_arn = join("", aws_ram_resource_share.default.*.id)
}

# https://www.terraform.io/docs/providers/aws/r/ram_principal_association.html
resource "aws_ram_principal_association" "default" {
  count              = local.enabled_count
  principal          = data.aws_organizations_organization.default.arn
  resource_share_arn = join("", aws_ram_resource_share.default.*.id)
}
