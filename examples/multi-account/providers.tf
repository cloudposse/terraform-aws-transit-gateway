provider "aws" {
  region = var.region
  alias  = "network"

  # assume_role {
  #   role_arn = ...
  # }
}

provider "aws" {
  region = var.region
  alias  = "prod"

  # assume_role {
  #   role_arn = ...
  # }
}

provider "aws" {
  region = var.region
  alias  = "staging"

  # assume_role {
  #   role_arn = ...
  # }
}

provider "aws" {
  region = var.region
  alias  = "dev"

  # assume_role {
  #   role_arn = ...
  # }
}
