terraform {
  required_version = ">= 0.13.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 1.2"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}
