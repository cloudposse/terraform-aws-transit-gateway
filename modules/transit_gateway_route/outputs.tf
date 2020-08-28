output "transit_gateway_route_ids" {
  value       = aws_ec2_transit_gateway_route.default.id
  description = "Transit Gateway Route Table identifiers combined with destinations"
}
