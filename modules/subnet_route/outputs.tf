output "transit_gateway_route_ids" {
  value       = aws_route.default.id
  description = "Route Table identifiers combined with destinations"
}
