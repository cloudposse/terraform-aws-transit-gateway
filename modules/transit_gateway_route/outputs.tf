output "transit_gateway_route_ids" {
  value       = map(var.stage, aws_ec2_transit_gateway_route.default[*].id)
  description = "Transit Gateway route identifiers combined with destinations"
}
