output "transit_gateway_arn" {
  value       = module.transit_gateway.transit_gateway_arn
  description = "Transit Gateway ARN"
}

output "transit_gateway_id" {
  value       = module.transit_gateway.transit_gateway_id
  description = "Transit Gateway ID"
}

output "transit_gateway_route_table_id" {
  value       = module.transit_gateway.transit_gateway_route_table_id
  description = "Transit Gateway route table ID"
}

output "transit_gateway_vpc_attachment_id_prod" {
  value       = module.transit_gateway_vpc_attachments_and_subnet_routes_prod.transit_gateway_vpc_attachment_ids["prod"]
  description = "Prod Transit Gateway VPC attachment ID"
}

output "transit_gateway_vpc_attachment_id_staging" {
  value       = module.transit_gateway_vpc_attachments_and_subnet_routes_staging.transit_gateway_vpc_attachment_ids["staging"]
  description = "Staging Transit Gateway VPC attachment ID"
}

output "transit_gateway_vpc_attachment_id_dev" {
  value       = module.transit_gateway_vpc_attachments_and_subnet_routes_dev.transit_gateway_vpc_attachment_ids["dev"]
  description = "Dev Transit Gateway VPC attachment ID"
}

output "transit_gateway_route_ids_prod" {
  value       = try(module.transit_gateway.transit_gateway_route_ids["prod"], {})
  description = "Prod Transit Gateway route identifiers combined with destinations"
}

output "transit_gateway_route_ids_staging" {
  value       = try(module.transit_gateway.transit_gateway_route_ids["staging"], {})
  description = "Staging Transit Gateway route identifiers combined with destinations"
}

output "transit_gateway_route_ids_dev" {
  value       = try(module.transit_gateway.transit_gateway_route_ids["dev"], {})
  description = "Dev Transit Gateway route identifiers combined with destinations"
}

output "subnet_route_ids_prod" {
  value       = try(module.transit_gateway_vpc_attachments_and_subnet_routes_prod.subnet_route_ids["prod"], {})
  description = "Prod subnet route identifiers combined with destinations"
}

output "subnet_route_ids_staging" {
  value       = try(module.transit_gateway_vpc_attachments_and_subnet_routes_staging.subnet_route_ids["staging"], {})
  description = "Staging subnet route identifiers combined with destinations"
}

output "subnet_route_ids_dev" {
  value       = try(module.transit_gateway_vpc_attachments_and_subnet_routes_dev.subnet_route_ids["dev"], {})
  description = "Dev subnet route identifiers combined with destinations"
}
