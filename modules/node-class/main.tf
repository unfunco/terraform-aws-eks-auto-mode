locals {
  spec = merge(
    # Required fields.
    var.instance_profile != null ? { instanceProfile = var.instance_profile } : {},
    var.role != null ? { role = var.role } : {},
    {
      securityGroupSelectorTerms = [
        for term in var.security_group_selector_terms : merge(
          term.id != null ? { id = term.id } : {},
          term.name != null ? { name = term.name } : {},
          term.tags != null ? { tags = term.tags } : {},
        )
      ]
      subnetSelectorTerms = [
        for term in var.subnet_selector_terms : merge(
          term.id != null ? { id = term.id } : {},
          term.tags != null ? { tags = term.tags } : {},
        )
      ]
    },
    # Optional fields.
    var.advanced_networking != null ? {
      advancedNetworking = {
        for k, v in var.advanced_networking : k => v if v != null
      }
    } : {},
    var.advanced_security != null ? {
      advancedSecurity = {
        for k, v in var.advanced_security : k => v if v != null
      }
    } : {},
    var.certificate_bundles != null ? { certificateBundles = var.certificate_bundles } : {},
    var.ephemeral_storage != null ? {
      ephemeralStorage = {
        for k, v in var.ephemeral_storage : k => v if v != null
      }
    } : {},
    var.pod_security_group_selector_terms != null ? {
      podSecurityGroupSelectorTerms = [
        for term in var.pod_security_group_selector_terms : merge(
          term.id != null ? { id = term.id } : {},
          term.name != null ? { name = term.name } : {},
          term.tags != null ? { tags = term.tags } : {},
        )
      ]
    } : {},
    var.pod_subnet_selector_terms != null ? {
      podSubnetSelectorTerms = [
        for term in var.pod_subnet_selector_terms : merge(
          term.id != null ? { id = term.id } : {},
          term.tags != null ? { tags = term.tags } : {},
        )
      ]
    } : {},
    var.network_policy != null ? { networkPolicy = var.network_policy } : {},
    var.snat_policy != null ? { snatPolicy = var.snat_policy } : {},
    var.tags != null ? { tags = var.tags } : {}
  )
}

resource "kubernetes_manifest" "node_class" {
  count = var.create ? 1 : 0

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodeClass"
    metadata   = { name = var.name }
    spec       = local.spec
  }
}

resource "aws_eks_access_entry" "this" {
  count = var.create && var.role != null ? 1 : 0

  cluster_name  = var.cluster_name
  principal_arn = var.role
  type          = "EC2"
}

resource "aws_eks_access_policy_association" "this" {
  count      = var.create && var.role != null ? 1 : 0
  depends_on = [aws_eks_access_entry.this]

  cluster_name = var.cluster_name
  policy_arn = format(
    "arn:%s:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy",
    data.aws_partition.this[0].partition,
  )

  principal_arn = var.role

  access_scope {
    type = "cluster"
  }
}
