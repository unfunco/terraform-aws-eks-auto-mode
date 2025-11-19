provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      project     = "platform"
      environment = "dev"
      managed-by  = "terraform"
    }
  }
}

module "network" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"

  name               = "workloads"
  cidr               = "10.42.0.0/16"
  azs                = slice(data.aws_availability_zones.these.names, 0, 3)
  private_subnets    = ["10.42.20.0/24", "10.42.21.0/24", "10.42.22.0/24"]
  public_subnets     = ["10.42.10.0/24", "10.42.11.0/24", "10.42.12.0/24"]
  intra_subnets      = ["10.42.30.0/24", "10.42.31.0/24", "10.42.32.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = false

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/workloads" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb"          = 1
    "kubernetes.io/cluster/workloads" = "shared"
  }

  intra_subnet_tags = {
    "kubernetes.io/role/pod-eni"      = 1
    "kubernetes.io/cluster/workloads" = "shared"
  }
}

module "workloads" {
  source = "../.."

  cluster_name    = "workloads"
  cluster_version = "1.30"
  subnet_ids      = module.network.private_subnets

  tags = {
    environment = "dev"
  }
}

resource "aws_security_group" "pod_enis" {
  name        = "workloads-pod-enis"
  description = "Restrict pod ENI traffic to the VPC"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "Allow pods to communicate inside the VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.network.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "workloads-pod-enis"
  }
}

data "aws_eks_cluster" "workloads" {
  name       = module.workloads.cluster_name
  depends_on = [module.workloads]
}

data "aws_eks_cluster_auth" "workloads" {
  name       = module.workloads.cluster_name
  depends_on = [module.workloads]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.workloads.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.workloads.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.workloads.token
}

module "node_class" {
  source = "../../modules/node-class"

  cluster_name = module.workloads.cluster_name
  name         = "private-app-nodes"
  role         = module.workloads.node_role_arn

  subnet_selector_terms = [
    for subnet_id in module.network.private_subnets : { id = subnet_id }
  ]

  pod_subnet_selector_terms = [
    for subnet_id in module.network.intra_subnets : { id = subnet_id }
  ]

  pod_security_group_selector_terms = [
    { id = aws_security_group.pod_enis.id }
  ]

  security_group_selector_terms = [
    {
      tags = {
        "aws:eks:cluster-name" = module.workloads.cluster_name
      }
    }
  ]

  advanced_security = {
    fips = true
  }

  ephemeral_storage = {
    size       = "200Gi"
    throughput = 1000
  }

  tags = {
    "eks.amazonaws.com/nodegroup" = "private-app"
    "owner"                       = "platform-team"
  }
}

module "node_pool" {
  source = "../../modules/node-pool"

  name            = "private-app"
  node_class_name = module.node_class.node_class_name

  labels = {
    workload = "private-app"
  }

  requirements = [
    {
      key      = "eks.amazonaws.com/instance-category"
      operator = "In"
      values   = ["c", "m"]
    },
    {
      key      = "eks.amazonaws.com/instance-cpu"
      operator = "In"
      values   = ["4", "8", "16"]
    },
    {
      key      = "topology.kubernetes.io/zone"
      operator = "In"
      values   = slice(data.aws_availability_zones.these.names, 0, 3)
    },
    {
      key      = "kubernetes.io/arch"
      operator = "In"
      values   = ["arm64", "amd64"]
    },
  ]

  limits = {
    cpu    = "500"
    memory = "400Gi"
  }

  disruption = {
    consolidation_policy = "WhenUnderutilized"
    budgets = [
      {
        nodes    = "10%"
        duration = "10m"
      }
    ]
  }

  expire_after = "336h"
  weight       = 50
}
