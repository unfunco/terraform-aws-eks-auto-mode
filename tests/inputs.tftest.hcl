# SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
# SPDX-License-Identifier: MIT

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      dns_suffix = "amazonaws.com"
      partition  = "aws"
    }
  }
}

variables {
  cluster_name = "workloads"
  subnet_ids   = ["subnet-0123456789abcdef0", "subnet-0fedcba9876543210"]
}

run "needs_only_a_name_and_subnets" {
  command = plan

  assert {
    condition     = aws_eks_cluster.this.compute_config[0].node_pools == toset(["general-purpose", "system"])
    error_message = "Both built-in node pools must be enabled by default."
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_private_access
    error_message = "The private endpoint must always be enabled."
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_public_access
    error_message = "The public endpoint must be enabled by default."
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].public_access_cidrs == toset(["0.0.0.0/0"])
    error_message = "The public endpoint must be open by default."
  }
}

run "restricts_the_public_endpoint" {
  command = plan

  variables {
    endpoint_public_access_cidrs = ["203.0.113.0/24"]
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_public_access
    error_message = "The public endpoint must stay enabled when CIDR blocks are given."
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].public_access_cidrs == toset(["203.0.113.0/24"])
    error_message = "The public endpoint must only admit the given CIDR blocks."
  }
}

run "turns_the_public_endpoint_off" {
  command = plan

  variables {
    endpoint_public_access_cidrs = []
  }

  assert {
    condition     = !aws_eks_cluster.this.vpc_config[0].endpoint_public_access
    error_message = "An empty list of CIDR blocks must disable the public endpoint."
  }

  assert {
    condition     = aws_eks_cluster.this.vpc_config[0].endpoint_private_access
    error_message = "The private endpoint must remain when the public one is off."
  }
}

run "pins_the_kubernetes_version" {
  command = plan

  variables {
    cluster_version = "1.37"
    node_pools      = ["general-purpose"]
  }

  assert {
    condition     = aws_eks_cluster.this.version == "1.37"
    error_message = "The cluster must use the requested Kubernetes version."
  }

  assert {
    condition     = aws_eks_cluster.this.compute_config[0].node_pools == toset(["general-purpose"])
    error_message = "Only the requested node pools must be enabled."
  }
}

run "rejects_invalid_inputs" {
  command = plan

  variables {
    cluster_log_types            = ["api", "kubelet"]
    cluster_name                 = "a-cluster-name-that-leaves-no-room-for-the-role-suffix"
    cluster_version              = "v1.37.0"
    endpoint_public_access_cidrs = ["203.0.113.0"]
    log_group_class              = "DELIVERY"
    node_pools                   = []
    subnet_ids                   = ["subnet-0123456789abcdef0"]
  }

  expect_failures = [
    var.cluster_log_types,
    var.cluster_name,
    var.cluster_version,
    var.endpoint_public_access_cidrs,
    var.log_group_class,
    var.node_pools,
    var.subnet_ids,
  ]
}
