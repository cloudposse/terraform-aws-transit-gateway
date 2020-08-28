variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "destination_cidr_block" {
  type        = string
  description = "Destination CIDR block"
}

variable "route_table_ids" {
  type        = set(string)
  description = "Subnet route table IDs"
}
