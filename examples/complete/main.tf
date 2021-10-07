provider "aws" {
  region = var.region
}

module "vpc_prod" {
  source  = "cloudposse/vpc/aws"
  version = "0.18.2"

  cidr_block = "172.16.0.0/16"

  enabled    = true
  attributes = ["prod"]
  context    = module.this.context
}

module "subnets_prod" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.34.0"

  availability_zones      = var.availability_zones
  vpc_id                  = module.vpc_prod.vpc_id
  igw_id                  = module.vpc_prod.igw_id
  cidr_block              = module.vpc_prod.vpc_cidr_block
  nat_gateway_enabled     = false
  nat_instance_enabled    = false
  map_public_ip_on_launch = false

  enabled    = true
  attributes = ["prod"]
  context    = module.this.context
}

module "vpc_staging" {
  source  = "cloudposse/vpc/aws"
  version = "0.18.2"

  cidr_block = "172.32.0.0/16"

  enabled    = true
  attributes = ["staging"]
  context    = module.this.context
}

module "subnets_staging" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.34.0"

  availability_zones      = var.availability_zones
  vpc_id                  = module.vpc_staging.vpc_id
  igw_id                  = module.vpc_staging.igw_id
  cidr_block              = module.vpc_staging.vpc_cidr_block
  nat_gateway_enabled     = false
  nat_instance_enabled    = false
  map_public_ip_on_launch = false

  enabled    = true
  attributes = ["staging"]
  context    = module.this.context
}

module "vpc_dev" {
  source  = "cloudposse/vpc/aws"
  version = "0.18.2"

  cidr_block = "172.48.0.0/16"

  enabled    = true
  attributes = ["dev"]
  context    = module.this.context
}

module "subnets_dev" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.34.0"

  availability_zones      = var.availability_zones
  vpc_id                  = module.vpc_dev.vpc_id
  igw_id                  = module.vpc_dev.igw_id
  cidr_block              = module.vpc_dev.vpc_cidr_block
  nat_gateway_enabled     = false
  nat_instance_enabled    = false
  map_public_ip_on_launch = false

  enabled    = true
  attributes = ["dev"]
  context    = module.this.context
}

locals {
  transit_gateway_config = {
    prod = {
      vpc_id                            = module.vpc_prod.vpc_id
      vpc_cidr                          = module.vpc_prod.vpc_cidr_block
      subnet_ids                        = module.subnets_prod.private_subnet_ids
      subnet_route_table_ids            = module.subnets_prod.private_route_table_ids
      route_to                          = ["staging", "dev"]
      route_to_cidr_blocks              = null
      transit_gateway_vpc_attachment_id = null
      static_routes = [
        {
          blackhole              = true
          destination_cidr_block = "0.0.0.0/0"
        },
        {
          blackhole              = false
          destination_cidr_block = "172.16.1.0/24"
        }
      ]
    },

    staging = {
      vpc_id                            = module.vpc_staging.vpc_id
      vpc_cidr                          = module.vpc_staging.vpc_cidr_block
      subnet_ids                        = module.subnets_staging.private_subnet_ids
      subnet_route_table_ids            = module.subnets_staging.private_route_table_ids
      route_to                          = null
      route_to_cidr_blocks              = [module.vpc_dev.vpc_cidr_block]
      transit_gateway_vpc_attachment_id = null
      static_routes = [
        {
          blackhole              = false
          destination_cidr_block = "172.32.1.0/24"
        }
      ]
    },

    dev = {
      vpc_id                            = module.vpc_dev.vpc_id
      vpc_cidr                          = module.vpc_dev.vpc_cidr_block
      subnet_ids                        = module.subnets_dev.private_subnet_ids
      subnet_route_table_ids            = module.subnets_dev.private_route_table_ids
      route_to                          = null
      route_to_cidr_blocks              = null
      transit_gateway_vpc_attachment_id = null
      static_routes                     = null
    }
  }
}

module "transit_gateway" {
  source = "../../"

  ram_resource_share_enabled = false
  config                     = local.transit_gateway_config

  context = module.this.context
}
