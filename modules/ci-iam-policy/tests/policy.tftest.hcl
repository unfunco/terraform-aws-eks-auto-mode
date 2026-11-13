# SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
# SPDX-License-Identifier: MIT

# The policy document is rendered by the real provider, which needs no
# credentials for it. Only the account lookup is replaced.
provider "aws" {
  access_key                  = "mock"
  region                      = "eu-west-2"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

override_data {
  target = data.aws_caller_identity.this
  values = {
    account_id = "123456789012"
  }
}

variables {
  cluster_name = "workloads"
}

run "scopes_every_statement_to_the_cluster" {
  command = plan

  assert {
    condition = toset(flatten([
      for statement in jsondecode(output.json).Statement :
      statement.Action if contains(flatten([statement.Resource]), "*")
    ])) == toset(["eks:CreateCluster", "logs:DescribeLogGroups"])
    error_message = "Only the two actions without resource-level permissions may apply to every resource."
  }

  assert {
    condition = one([
      for statement in jsondecode(output.json).Statement :
      statement.Resource if statement.Sid == "ManageCluster"
    ]) == "arn:aws:eks:eu-west-2:123456789012:cluster/workloads"
    error_message = "Cluster actions must be limited to the named cluster."
  }

  assert {
    condition = toset(one([
      for statement in jsondecode(output.json).Statement :
      statement.Resource if statement.Sid == "ManageRoles"
      ])) == toset([
      "arn:aws:iam::123456789012:role/workloads-cluster-role",
      "arn:aws:iam::123456789012:role/workloads-node-role",
    ])
    error_message = "Role actions must be limited to the two roles the root module creates."
  }
}

run "guards_against_privilege_escalation" {
  command = plan

  assert {
    condition = length(one([
      for statement in jsondecode(output.json).Statement :
      statement.Condition.ArnEquals["iam:PolicyARN"] if statement.Sid == "AttachManagedPolicies"
    ])) == 7
    error_message = "Only the seven managed policies the root module uses may be attached."
  }

  assert {
    condition = one([
      for statement in jsondecode(output.json).Statement :
      statement.Condition.StringEquals["iam:PassedToService"] if statement.Sid == "PassRolesToEKS"
    ]) == "eks.amazonaws.com"
    error_message = "The roles may only be passed to EKS."
  }
}

run "leaves_out_kms_without_keys" {
  command = plan

  assert {
    condition = !contains([
      for statement in jsondecode(output.json).Statement : statement.Sid
    ], "UseEncryptionKeys")
    error_message = "No KMS statement is expected without keys."
  }
}

run "grants_use_of_the_given_keys" {
  command = plan

  variables {
    kms_key_arns = ["arn:aws:kms:eu-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"]
  }

  assert {
    condition = one([
      for statement in jsondecode(output.json).Statement :
      statement.Resource if statement.Sid == "UseEncryptionKeys"
    ]) == "arn:aws:kms:eu-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
    error_message = "KMS actions must be limited to the given keys."
  }
}
