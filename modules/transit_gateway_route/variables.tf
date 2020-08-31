variable "transit_gateway_attachment_id" {
  type        = string
  description = "Transit Gateway VPC attachment ID"
}

variable "transit_gateway_route_table_id" {
  type        = string
  description = "Transit Gateway route table ID"
}

variable "route_config" {
  type = list(object({
    blackhole              = bool
    destination_cidr_block = string
  }))
  description = "Route config"
}
