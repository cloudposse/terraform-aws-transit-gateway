# Create the Transit Gateway, route table associations/propagations, and static TGW routes in the `network` account.
# Enable sharing the Transit Gateway with the Organization using Resource Access Manager (RAM).
# If you would like to share resources with your organization or organizational units,
# then you must use the AWS RAM console or CLI command to enable sharing with AWS Organizations.
# When you share resources within your organization,
# AWS RAM does not send invitations to principals. Principals in your organization get access to shared resources without exchanging invitations.
# https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html

module "transit_gateway" {
  source = "../../"

  ram_resource_share_enabled = true

  create_transit_gateway                                         = true
  create_transit_gateway_route_table                             = true
  create_transit_gateway_vpc_attachment                          = false
  create_transit_gateway_route_table_association_and_propagation = true

  config = {
    prod = {
      vpc_id                            = null
      vpc_cidr                          = null
      subnet_ids                        = null
      subnet_route_table_ids            = null
      route_to                          = null
      route_to_cidr_blocks              = null
      transit_gateway_vpc_attachment_id = module.transit_gateway_vpc_attachments_and_subnet_routes_prod.transit_gateway_vpc_attachment_ids["prod"]
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
      vpc_id                            = null
      vpc_cidr                          = null
      subnet_ids                        = null
      subnet_route_table_ids            = null
      route_to                          = null
      route_to_cidr_blocks              = null
      transit_gateway_vpc_attachment_id = module.transit_gateway_vpc_attachments_and_subnet_routes_staging.transit_gateway_vpc_attachment_ids["staging"]
      static_routes = [
        {
          blackhole              = false
          destination_cidr_block = "172.32.1.0/24"
        }
      ]
    },
    dev = {
      vpc_id                            = null
      vpc_cidr                          = null
      subnet_ids                        = null
      subnet_route_table_ids            = null
      route_to                          = null
      route_to_cidr_blocks              = null
      static_routes                     = null
      transit_gateway_vpc_attachment_id = module.transit_gateway_vpc_attachments_and_subnet_routes_dev.transit_gateway_vpc_attachment_ids["dev"]
    }
  }

  context = module.this.context

  providers = {
    aws = aws.network
  }
}


# Create the Transit Gateway VPC attachments and subnets routes in the `prod`, `staging` and `dev` accounts

module "transit_gateway_vpc_attachments_and_subnet_routes_prod" {
  source = "../../"

  # `prod` account can access the Transit Gateway in the `network` account since we shared the Transit Gateway with the Organization using Resource Access Manager
  existing_transit_gateway_id             = module.transit_gateway.transit_gateway_id
  existing_transit_gateway_route_table_id = module.transit_gateway.transit_gateway_route_table_id

  create_transit_gateway                                         = false
  create_transit_gateway_route_table                             = false
  create_transit_gateway_vpc_attachment                          = true
  create_transit_gateway_route_table_association_and_propagation = false

  config = {
    prod = {
      vpc_id                 = module.vpc_prod.vpc_id
      vpc_cidr               = module.vpc_prod.vpc_cidr_block
      subnet_ids             = module.subnets_prod.private_subnet_ids
      subnet_route_table_ids = module.subnets_prod.private_route_table_ids
      route_to               = null
      route_to_cidr_blocks = [
        module.vpc_staging.vpc_cidr_block,
        module.vpc_dev.vpc_cidr_block
      ]
      static_routes                     = null
      transit_gateway_vpc_attachment_id = null
    }
  }

  context = module.this.context

  providers = {
    aws = aws.prod
  }
}

module "transit_gateway_vpc_attachments_and_subnet_routes_staging" {
  source = "../../"

  # `staging` account can access the Transit Gateway in the `network` account since we shared the Transit Gateway with the Organization using Resource Access Manager
  existing_transit_gateway_id             = module.transit_gateway.transit_gateway_id
  existing_transit_gateway_route_table_id = module.transit_gateway.transit_gateway_route_table_id

  create_transit_gateway                                         = false
  create_transit_gateway_route_table                             = false
  create_transit_gateway_vpc_attachment                          = true
  create_transit_gateway_route_table_association_and_propagation = false

  config = {
    staging = {
      vpc_id                 = module.vpc_staging.vpc_id
      vpc_cidr               = module.vpc_staging.vpc_cidr_block
      subnet_ids             = module.subnets_staging.private_subnet_ids
      subnet_route_table_ids = module.subnets_staging.private_route_table_ids
      route_to               = null
      route_to_cidr_blocks = [
        module.vpc_dev.vpc_cidr_block
      ]
      static_routes                     = null
      transit_gateway_vpc_attachment_id = null
    }
  }

  context = module.this.context

  providers = {
    aws = aws.staging
  }
}

module "transit_gateway_vpc_attachments_and_subnet_routes_dev" {
  source = "../../"

  # `dev` account can access the Transit Gateway in the `network` account since we shared the Transit Gateway with the Organization using Resource Access Manager
  existing_transit_gateway_id             = module.transit_gateway.transit_gateway_id
  existing_transit_gateway_route_table_id = module.transit_gateway.transit_gateway_route_table_id

  create_transit_gateway                                         = false
  create_transit_gateway_route_table                             = false
  create_transit_gateway_vpc_attachment                          = true
  create_transit_gateway_route_table_association_and_propagation = false

  config = {
    dev = {
      vpc_id                            = module.vpc_dev.vpc_id
      vpc_cidr                          = module.vpc_dev.vpc_cidr_block
      subnet_ids                        = module.subnets_dev.private_subnet_ids
      subnet_route_table_ids            = module.subnets_dev.private_route_table_ids
      route_to                          = null
      route_to_cidr_blocks              = null
      static_routes                     = null
      transit_gateway_vpc_attachment_id = null
    }
  }

  context = module.this.context

  providers = {
    aws = aws.dev
  }
}
