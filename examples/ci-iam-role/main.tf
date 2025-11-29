provider "aws" {}

module "workloads_deployer_iam_policy" {
  source = "../../modules/ci-iam-policy"

  cluster_name = "workloads"
}

module "oidc_github" {
  source  = "unfunco/oidc-github/aws"
  version = "2.0.2"

  github_repositories = ["unfunco/terraform-aws-eks-auto-mode"]
  iam_role_inline_policies = {
    eks = module.workloads_deployer_iam_policy.policy_document.json
  }
}
