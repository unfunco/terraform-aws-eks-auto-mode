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

run "creates_an_auto_mode_cluster" {
  command = plan

  assert {
    condition     = aws_eks_cluster.this.name == "workloads"
    error_message = "The cluster must take its name from cluster_name."
  }

  assert {
    condition     = aws_eks_cluster.this.bootstrap_self_managed_addons == false
    error_message = "Auto Mode clusters must not bootstrap self-managed add-ons."
  }

  assert {
    condition     = aws_eks_cluster.this.compute_config[0].enabled
    error_message = "Auto Mode compute must be enabled."
  }

  assert {
    condition     = aws_eks_cluster.this.kubernetes_network_config[0].elastic_load_balancing[0].enabled
    error_message = "Auto Mode load balancing must be enabled."
  }

  assert {
    condition     = aws_eks_cluster.this.storage_config[0].block_storage[0].enabled
    error_message = "Auto Mode block storage must be enabled."
  }

  assert {
    condition     = aws_eks_cluster.this.access_config[0].authentication_mode == "API"
    error_message = "The cluster must authenticate with access entries only."
  }
}

run "attaches_the_auto_mode_managed_policies" {
  command = plan

  assert {
    condition = toset(keys(aws_iam_role_policy_attachment.cluster)) == toset([
      "AmazonEKSBlockStoragePolicy",
      "AmazonEKSClusterPolicy",
      "AmazonEKSComputePolicy",
      "AmazonEKSLoadBalancingPolicy",
      "AmazonEKSNetworkingPolicy",
    ])
    error_message = "The cluster role must have the five Auto Mode managed policies."
  }

  assert {
    condition = toset(keys(aws_iam_role_policy_attachment.node)) == toset([
      "AmazonEC2ContainerRegistryPullOnly",
      "AmazonEKSWorkerNodeMinimalPolicy",
    ])
    error_message = "The node role must have the two minimal node policies."
  }

  assert {
    condition     = aws_iam_role_policy_attachment.node["AmazonEKSWorkerNodeMinimalPolicy"].policy_arn == "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
    error_message = "Managed policy ARNs must be built from the partition."
  }
}

run "names_the_log_group_after_the_cluster" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_group.this.name == "/aws/eks/workloads/cluster"
    error_message = "EKS only writes control plane logs to /aws/eks/<cluster>/cluster."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.skip_destroy
    error_message = "Control plane logs must outlive the cluster unless force_destroy is set."
  }
}
