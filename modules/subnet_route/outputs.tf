output "subnet_route_ids" {
  value       = compact(concat(values(aws_route.keys)[*].id, aws_route.count[*].id))
  description = "Subnet route identifiers combined with destinations"
}
