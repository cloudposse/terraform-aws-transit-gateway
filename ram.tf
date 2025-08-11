locals {
  ram_principals_provided = var.ram_principal != null || length(var.ram_principals) > 0
  ram_principals = toset(var.ram_resource_share_enabled && local.ram_principals_provided ? toset(
    concat(
      var.ram_principal == null ? [] : [var.ram_principal],
      var.ram_principals,
    )
  ) : [])
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
  count = var.ram_resource_share_enabled && !local.ram_principals_provided ? 1 : 0
}

resource "aws_ram_resource_association" "default" {
  count              = var.ram_resource_share_enabled ? 1 : 0
  resource_arn       = try(data.aws_ec2_transit_gateway.this[0].arn, "")
  resource_share_arn = try(aws_ram_resource_share.default[0].id, "")

  depends_on = [
    data.aws_ec2_transit_gateway.this,
    aws_ram_resource_share.default
  ]
}

resource "aws_ram_principal_association" "default" {
  for_each           = local.ram_principals
  principal          = each.value
  resource_share_arn = try(aws_ram_resource_share.default[0].id, "")

  depends_on = [
    aws_ram_resource_share.default
  ]
}

resource "aws_ram_principal_association" "org_arn" {
  count              = var.ram_resource_share_enabled && !local.ram_principals_provided ? 1 : 0
  principal          = data.aws_organizations_organization.default[0].arn
  resource_share_arn = try(aws_ram_resource_share.default[0].id, "")

  depends_on = [
    aws_ram_resource_share.default,
    data.aws_organizations_organization.default
  ]
}
