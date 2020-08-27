terraform {
  required_version = "~> 0.12.0"

  required_providers {
    local  = "~> 1.2"
    random = "~> 2.2"
    aws    = ">= 2.34, < 4.0"
  }
}
