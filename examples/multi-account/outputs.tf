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

output "transit_gateway_association_default_route_table_id" {
  value       = module.transit_gateway.transit_gateway_association_default_route_table_id
  description = "Transit Gateway association default route table ID"
}

output "transit_gateway_propagation_default_route_table_id" {
  value       = module.transit_gateway.transit_gateway_propagation_default_route_table_id
  description = "Transit Gateway propagation default route table ID"
}

output "transit_gateway_vpc_attachment_ids" {
  value       = module.transit_gateway.transit_gateway_vpc_attachment_ids
  description = "Transit Gateway VPC attachment IDs"
}

output "transit_gateway_route_ids" {
  value       = module.transit_gateway.transit_gateway_route_ids
  description = "Transit Gateway route identifiers combined with destinations"
}

output "subnet_route_ids" {
  value       = module.transit_gateway.subnet_route_ids
  description = "Subnet route identifiers combined with destinations"
}
