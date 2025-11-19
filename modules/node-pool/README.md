# Custom NodePool module

<!-- BEGIN_TF_DOCS -->

### Resources

| Name                                                                                                                  | Type     |
| --------------------------------------------------------------------------------------------------------------------- | -------- |
| [kubernetes_manifest.node_pool](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |

### Inputs

| Name                      | Description                                                                                | Type                                                                                                                                  | Default | Required |
| ------------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| annotations               | Annotations to apply to the NodePool template metadata.                                    | `map(string)`                                                                                                                         | `{}`    |    no    |
| create                    | Enable/disable the creation of all resources.                                              | `bool`                                                                                                                                | `true`  |    no    |
| disruption                | Disruption settings controlling consolidation and budgets.                                 | `object({ budgets = optional(list(object({ duration = optional(string) nodes = optional(string) }))) consolidate_after = optional(string) consolidation_policy = optional(string) })` | `null`  |    no    |
| expire_after              | How long nodes should live before being rotated (for example 336h).                        | `string`                                                                                                                              | `null`  |    no    |
| labels                    | Labels to apply to the NodePool template metadata.                                         | `map(string)`                                                                                                                         | `{}`    |    no    |
| limits                    | Resource limits for the NodePool (for example cpu, memory).                                | `object({ cpu = optional(string) memory = optional(string) })`                                                                        | `null`  |    no    |
| name                      | Name of the NodePool.                                                                      | `string`                                                                                                                              | n/a     |   yes    |
| node_class_group          | API group of the NodeClass resource.                                                       | `string`                                                                                                                              | `"eks.amazonaws.com"` |    no    |
| node_class_kind           | Kind of the NodeClass resource.                                                            | `string`                                                                                                                              | `"NodeClass"` |    no    |
| node_class_name           | Name of the NodeClass this pool should use.                                                | `string`                                                                                                                              | n/a     |   yes    |
| requirements              | Scheduling requirements for the NodePool (for example instance families, CPU, zones).      | `list(object({ key = string operator = string values = list(string) }))`                                                              | `[]`    |    no    |
| startup_taints            | Taints that are set when the node starts up and removed after initialization.              | `list(object({ key = string value = optional(string) effect = string }))`                                                             | `[]`    |    no    |
| taints                    | Taints to apply to nodes launched by this pool.                                            | `list(object({ key = string value = optional(string) effect = string }))`                                                             | `[]`    |    no    |
| termination_grace_period  | Grace period before terminating nodes (for example 24h).                                   | `string`                                                                                                                              | `null`  |    no    |
| weight                    | Relative scheduling weight for this NodePool.                                              | `number`                                                                                                                              | `null`  |    no    |

### Outputs

| Name            | Description                    |
| --------------- | ------------------------------ |
| node_pool_name  | Name of the created NodePool.  |

<!-- END_TF_DOCS -->

## License

© 2025 [Daniel Morris]\
Made available under the terms of the [MIT License].

[daniel morris]: https://unfun.co
[mit license]: ../../LICENSE.md
