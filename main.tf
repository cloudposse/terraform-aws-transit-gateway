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

resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
  for_each           = var.config
  transit_gateway_id = aws_ec2_transit_gateway.default.id
  # provider                                        = "aws" #try(each.value["provider"], "aws")
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
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

# Allow traffic from the Transit Gateway to the VPC attachments
# Propagations will create propagated routes
resource "aws_ec2_transit_gateway_route_table_propagation" "default" {
  for_each                       = var.config
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
}

# Static Transit Gateway routes
# Static routes have a higher precedence than propagated routes
# https://docs.aws.amazon.com/vpc/latest/tgw/how-transit-gateways-work.html
# https://docs.aws.amazon.com/vpc/latest/tgw/tgw-route-tables.html
module "transit_gateway_route" {
  source                         = "./modules/transit_gateway_route"
  for_each                       = var.config
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.default[each.key]["id"]
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.default.id
  route_config                   = try(each.value["static_routes"], [])
}

# Create routes in the subnets' route tables to route traffic from subnets to the Transit Gateway VPC attachments
# Only route to VPCs of the environments defined in `route_to` attribute
module "subnet_route" {
  source                  = "./modules/subnet_route"
  for_each                = var.config
  transit_gateway_id      = aws_ec2_transit_gateway.default.id
  aws_provider            = try(each.value["provider"], "aws")
  route_table_ids         = try(each.value["subnet_route_table_ids"], [])
  destination_cidr_blocks = toset([for i in setintersection(keys(var.config), try(each.value["route_to"], [])) : var.config[i]["vpc_cidr"]])
}
