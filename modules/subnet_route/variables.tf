variable "transit_gateway_id" {
  type        = string
  description = "Transit Gateway ID"
}

variable "route_table_ids" {
  type        = list(string)
  description = "Subnet route table IDs"
}

variable "destination_cidr_blocks" {
  type        = list(string)
  description = "Destination CIDR blocks"
}

variable "stage" {
  type        = string
  description = "Stage to create the Transit Gateway routes for (e.g. `prod`, `staging`, `dev`)"
}
