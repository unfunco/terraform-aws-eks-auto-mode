provider "aws" {}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  azs                = slice(data.aws_availability_zones.these.names, 0, 2)
  cidr               = "10.0.0.0/16"
  enable_nat_gateway = true
  name               = "network"
  private_subnets    = ["10.0.20.0/24", "10.0.21.0/24"]
  public_subnets     = ["10.0.10.0/24", "10.0.11.0/24"]
  single_nat_gateway = true
}

module "workloads" {
  source = "../.."

  cluster_name = "workloads"
  subnet_ids   = module.network.private_subnets
}
