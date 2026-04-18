// SPDX-FileCopyrightText: 2026 Daniel Morris <daniel@honestempire.com>
// SPDX-License-Identifier: MIT

provider "aws" {}

module "workloads_deployer_iam_policy" {
  source = "../../modules/ci-iam-policy"

  cluster_name = "workloads"
}

module "oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "3.0.0"

  github_subjects = ["unfunco/terraform-aws-eks-auto-mode"]
  iam_role_inline_policies = {
    eks = module.workloads_deployer_iam_policy.policy_document.json
  }
}
