provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = local.default_tags
  }
}

locals {
  default_tags = {
    environment = "sandbox"
    managed-by  = "terraform"
    project     = "platform"
  }
}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  azs                = slice(data.aws_availability_zones.these.names, 0, 3)
  cidr               = "10.20.0.0/16"
  enable_nat_gateway = true
  name               = "workloads"
  private_subnets    = ["10.20.20.0/24", "10.20.21.0/24", "10.20.22.0/24"]
  public_subnets     = ["10.20.10.0/24", "10.20.11.0/24", "10.20.12.0/24"]
  single_nat_gateway = true
  tags               = local.default_tags

  private_subnet_tags = {
    "kubernetes.io/cluster/workloads" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/workloads" = "shared"
    "kubernetes.io/role/elb"          = 1
  }
}

module "workloads" {
  source = "../.."

  cluster_name  = "workloads"
  force_destroy = true
  subnet_ids    = module.network.private_subnets
  tags          = local.default_tags
}
