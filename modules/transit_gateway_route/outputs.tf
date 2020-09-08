output "transit_gateway_route_ids" {
  value       = try(aws_ec2_transit_gateway_route.default[*].id, [])
  description = "Transit Gateway route identifiers combined with destinations"
}
