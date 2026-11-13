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

run "uses_aws_owned_keys_by_default" {
  command = plan

  assert {
    condition     = length(aws_eks_cluster.this.encryption_config) == 0
    error_message = "No encryption configuration is expected without a key."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.kms_key_id == null
    error_message = "The log group must not name a key when none is given."
  }
}

run "shares_one_key_between_secrets_and_logs" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:eu-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
  }

  assert {
    condition     = aws_eks_cluster.this.encryption_config[0].resources == toset(["secrets"])
    error_message = "EKS can only envelope-encrypt secrets."
  }

  assert {
    condition     = aws_eks_cluster.this.encryption_config[0].provider[0].key_arn == var.kms_key_arn
    error_message = "Secrets must be encrypted with kms_key_arn."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.kms_key_id == var.kms_key_arn
    error_message = "Logs must be encrypted with kms_key_arn."
  }
}

run "prefers_the_more_specific_keys" {
  command = plan

  variables {
    kms_key_arn           = "arn:aws:kms:eu-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
    kms_key_arn_cluster   = "arn:aws:kms:eu-west-2:123456789012:key/22222222-2222-2222-2222-222222222222"
    kms_key_arn_log_group = "arn:aws:kms:eu-west-2:123456789012:key/33333333-3333-3333-3333-333333333333"
  }

  assert {
    condition     = aws_eks_cluster.this.encryption_config[0].provider[0].key_arn == var.kms_key_arn_cluster
    error_message = "Secrets must be encrypted with kms_key_arn_cluster."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.kms_key_id == var.kms_key_arn_log_group
    error_message = "Logs must be encrypted with kms_key_arn_log_group."
  }
}

run "encrypts_secrets_with_only_a_cluster_key" {
  command = plan

  variables {
    kms_key_arn_cluster = "arn:aws:kms:eu-west-2:123456789012:key/22222222-2222-2222-2222-222222222222"
  }

  assert {
    condition     = aws_eks_cluster.this.encryption_config[0].provider[0].key_arn == var.kms_key_arn_cluster
    error_message = "Secrets must be encrypted with kms_key_arn_cluster on its own."
  }

  assert {
    condition     = aws_cloudwatch_log_group.this.kms_key_id == null
    error_message = "The log group must not borrow the cluster key."
  }
}
