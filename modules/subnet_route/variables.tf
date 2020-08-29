variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "route_table_ids" {
  type        = set(string)
  description = "Subnet route table IDs"
}

variable "destination_cidr_blocks" {
  type        = set(string)
  description = "Destination CIDR blocks"
}

variable "aws_provider" {
  type        = string
  description = "AWS provider"
}
