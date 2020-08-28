resource "aws_ec2_transit_gateway" "default" {
  description                     = format("%s Transit Gateway", module.this.id)
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support
  tags                            = module.this.tags
}

resource "aws_ec2_transit_gateway_route_table" "default" {
  transit_gateway_id = aws_ec2_transit_gateway.default.id
  tags               = module.this.tags
}

# RAM share for Transit Gateway
resource "aws_ram_resource_share" "default" {
  name                      = module.this.id
  allow_external_principals = var.allow_external_principals
  tags                      = module.this.tags
}

# Share the Transit Gateway with the Organization
data "aws_organizations_organization" "default" {}

resource "aws_ram_resource_association" "default" {
  resource_arn       = aws_ec2_transit_gateway.default.arn
  resource_share_arn = aws_ram_resource_share.default.id
}

resource "aws_ram_principal_association" "default" {
  principal          = data.aws_organizations_organization.default.arn
  resource_share_arn = aws_ram_resource_share.default.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  for_each                                        = var.config
  transit_gateway_id                              = aws_ec2_transit_gateway.default.id
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
resource "aws_ec2_transit_gateway_route_table_association" "default" {
  for_each                       = var.config
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "default" {
  for_each                       = var.config
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

# Static Transit Gateway routes
# Static routes have a higher precedence than propagated routes
# https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
module "transit_gateway_route" {
  source                         = "modules/transit_gateway_route"
  for_each                       = var.config
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
  config                         = each.value["static_routes"]
}

# Create routes in the subnets' route tables to roue traffic from subnets to the Transit Gateway VPC attachments
# Only route to VPCs of the environments defined in `route_to` attribute
module "subnet_route" {
  source                  = "modules/subnet_route"
  for_each                = var.config
  transit_gateway_id      = aws_ec2_transit_gateway.default.id
  provider                = each.value["provider"]
  route_table_ids         = each.value["subnet_route_table_ids"]
  destination_cidr_blocks = toset([for i in setintersection(keys(var.config), each.value["route_to"]) : i["vpc_cidr"]])
}
