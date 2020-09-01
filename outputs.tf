output "transit_gateway_arn" {
  value       = aws_ec2_transit_gateway.default.arn
  description = "Transit Gateway ARN"
}

output "transit_gateway_id" {
  value       = aws_ec2_transit_gateway.default.id
  description = "Transit Gateway ID"
}

output "transit_gateway_route_table_id" {
  value       = aws_ec2_transit_gateway_route_table.default.id
  description = "Transit Gateway route table ID"
}

output "transit_gateway_association_default_route_table_id" {
  value       = aws_ec2_transit_gateway.default.association_default_route_table_id
  description = "Transit Gateway association default route table ID"
}

output "transit_gateway_propagation_default_route_table_id" {
  value       = aws_ec2_transit_gateway.default.propagation_default_route_table_id
  description = "Transit Gateway propagation default route table ID"
}

output "transit_gateway_vpc_attachment_ids" {
  value       = { for i, o in aws_ec2_transit_gateway_vpc_attachment.default : i => o["id"] }
  description = "Transit Gateway VPC attachment IDs"
}

output "transit_gateway_route_ids" {
  value       = { for i, o in module.transit_gateway_route : i => o["transit_gateway_route_ids"] }
  description = "Transit Gateway route identifiers combined with destinations"
}

output "subnet_route_ids" {
  value       = { for i, o in module.subnet_route : i => o["subnet_route_ids"] }
  description = "Subnet route identifiers combined with destinations"
}
