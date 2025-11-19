locals {
  template_metadata = merge(
    length(var.annotations) > 0 ? { annotations = var.annotations } : {},
    length(var.labels) > 0 ? { labels = var.labels } : {}
  )

  template_spec = merge(
    {
      nodeClassRef = {
        group = var.node_class_group
        kind  = var.node_class_kind
        name  = var.node_class_name
      }
    },
    length(var.requirements) > 0 ? {
      requirements = [
        for requirement in var.requirements : {
          key      = requirement.key
          operator = requirement.operator
          values   = requirement.values
        }
      ]
    } : {},
    length(var.taints) > 0 ? {
      taints = [
        for taint in var.taints : merge(
          { key = taint.key, effect = taint.effect },
          taint.value != null ? { value = taint.value } : {}
        )
      ]
    } : {},
    length(var.startup_taints) > 0 ? {
      startupTaints = [
        for taint in var.startup_taints : merge(
          { key = taint.key, effect = taint.effect },
          taint.value != null ? { value = taint.value } : {}
        )
      ]
    } : {},
    var.expire_after != null ? { expireAfter = var.expire_after } : {},
    var.termination_grace_period != null ? {
      terminationGracePeriod = var.termination_grace_period
    } : {}
  )

  spec = merge(
    {
      template = merge(
        { spec = local.template_spec },
        length(local.template_metadata) > 0 ? { metadata = local.template_metadata } : {}
      )
    },
    var.disruption != null ? {
      disruption = merge(
        var.disruption.consolidation_policy != null ? {
          consolidationPolicy = var.disruption.consolidation_policy
        } : {},
        var.disruption.consolidate_after != null ? {
          consolidateAfter = var.disruption.consolidate_after
        } : {},
        var.disruption.budgets != null ? {
          budgets = [
            for budget in var.disruption.budgets : {
              for k, v in {
                duration = budget.duration
                nodes    = budget.nodes
              } : k => v if v != null
            }
          ]
        } : {}
      )
    } : {},
    var.limits != null ? {
      limits = {
        for k, v in var.limits : k => v if v != null
      }
    } : {},
    var.weight != null ? { weight = var.weight } : {}
  )
}

resource "kubernetes_manifest" "node_pool" {
  count = var.create ? 1 : 0

  manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"
    metadata   = { name = var.name }
    spec       = local.spec
  }
}
