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

variable "route_keys_enabled" {
  type    = bool
  default = false
}

variable "route_timeouts" {
  type = object({
    create = optional(string),
    delete = optional(string),
    update = optional(string)
  })
  description = "aws_route resource timeouts"
  default = {}
}
