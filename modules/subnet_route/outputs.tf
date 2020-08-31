output "subnet_route_ids" {
  value       = map(var.stage, aws_route.default[*].id)
  description = "Subnet route identifiers combined with destinations"
}
