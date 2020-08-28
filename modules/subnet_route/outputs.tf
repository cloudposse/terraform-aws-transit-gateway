output "subnet_route_ids" {
  value       = aws_route.default.id
  description = "Subnet route identifiers combined with destinations"
}
