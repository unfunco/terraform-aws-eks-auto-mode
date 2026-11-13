// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

provider "aws" {
  default_tags {
    tags = { example = true }
  }
}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  azs                 = slice(data.aws_availability_zones.these.names, 0, 2)
  cidr                = "10.0.0.0/16"
  enable_nat_gateway  = true
  name                = "network"
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }
  private_subnets     = ["10.0.20.0/24", "10.0.21.0/24"]
  public_subnet_tags  = { "kubernetes.io/role/elb" = "1" }
  public_subnets      = ["10.0.10.0/24", "10.0.11.0/24"]
  single_nat_gateway  = true
}

module "workloads" {
  source = "../.."

  cluster_name  = "workloads"
  force_destroy = true
  subnet_ids    = module.network.private_subnets
}
