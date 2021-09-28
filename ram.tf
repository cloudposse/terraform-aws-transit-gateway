locals {
  ram_principals = var.ram_resource_share_enabled ? toset(coalesce(var.ram_principals, [try(data.aws_organizations_organization.default[0].arn, "")])) : toset([])
}

# Resource Access Manager (RAM) share for the Transit Gateway
# https://docs.aws.amazon.com/ram/latest/userguide/what-is.html
resource "aws_ram_resource_share" "default" {
  count                     = var.ram_resource_share_enabled ? 1 : 0
  name                      = module.this.id
  allow_external_principals = var.allow_external_principals
  tags                      = module.this.tags
}

# Share the Transit Gateway with the Organization if RAM principal was not provided
data "aws_organizations_organization" "default" {
  count = var.ram_resource_share_enabled && length(coalesce(var.ram_principals, [])) == 0 ? 1 : 0
}

resource "aws_ram_resource_association" "default" {
  count              = var.ram_resource_share_enabled ? 1 : 0
  resource_arn       = try(aws_ec2_transit_gateway.default[0].arn, "")
  resource_share_arn = try(aws_ram_resource_share.default[0].id, "")
}

resource "aws_ram_principal_association" "default" {
  for_each = local.ram_principals

  principal          = each.value
  resource_share_arn = try(aws_ram_resource_share.default[0].id, "")
}
