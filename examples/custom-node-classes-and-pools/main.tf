provider "aws" {
  default_tags {
    tags = { example = true }
  }
}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  azs                = slice(data.aws_availability_zones.these.names, 0, 2)
  cidr               = "10.0.0.0/16"
  enable_nat_gateway = true
  name               = "network"
  private_subnets    = ["10.0.20.0/24", "10.0.21.0/24"]
  public_subnets     = ["10.0.10.0/24", "10.0.11.0/24"]
  single_nat_gateway = false
}

module "workloads" {
  source = "../.."

  cluster_name  = "workloads"
  force_destroy = true
  subnet_ids    = module.network.private_subnets
}

module "node_class" {
  source = "../../modules/node-class"

  cluster_name = module.workloads.cluster_name
  name         = "custom-node-class"
  role         = module.workloads.node_role_arn

  subnet_selector_terms = [
    {
      tags = {
        "kubernetes.io/role/internal-elb" = "1"
      }
    }
  ]

  security_group_selector_terms = [
    {
      tags = {
        "aws:eks:cluster-name" = module.workloads.cluster_name
      }
    }
  ]

  ephemeral_storage = {
    size = "100Gi"
  }
}
