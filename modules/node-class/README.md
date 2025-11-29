# Custom node class module

<!-- BEGIN_TF_DOCS -->

### Resources

| Name                                                                                                                                                | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_eks_access_entry.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry)                           | resource    |
| [aws_eks_access_policy_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource    |
| [kubernetes_manifest.node_class](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest)                       | resource    |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                                      | data source |

### Inputs

| Name                              | Description                                                                | Type                                                                                                                    | Default | Required |
| --------------------------------- | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ------- | :------: |
| advanced_networking               | Advanced networking configuration.                                         | `object({ associatePublicIPAddress = optional(bool) httpsProxy = optional(string) noProxy = optional(list(string)) })`  | `null`  |    no    |
| advanced_security                 | Advanced security configuration.                                           | `object({ fips = optional(bool) })`                                                                                     | `null`  |    no    |
| certificate_bundles               | Base64-encoded custom certificate bundles.                                 | `list(string)`                                                                                                          | `null`  |    no    |
| cluster_name                      | Name of the EKS cluster.                                                   | `string`                                                                                                                | n/a     |   yes    |
| create                            | Enable/disable the creation of all resources.                              | `bool`                                                                                                                  | `true`  |    no    |
| ephemeral_storage                 | Ephemeral storage configuration.                                           | `object({ iops = optional(number) kmsKeyID = optional(string) size = optional(string) throughput = optional(number) })` | `null`  |    no    |
| instance_profile                  | Instance profile name for EC2 instances. Mutually exclusive with role.     | `string`                                                                                                                | `null`  |    no    |
| name                              | Name of the NodeClass.                                                     | `string`                                                                                                                | n/a     |   yes    |
| network_policy                    | Network policy for the NodeClass. Valid values: DefaultAllow, DefaultDeny. | `string`                                                                                                                | `null`  |    no    |
| pod_security_group_selector_terms | Pod security group selector terms.                                         | `list(object({ id = optional(string) name = optional(string) tags = optional(map(string)) }))`                          | `null`  |    no    |
| pod_subnet_selector_terms         | Pod subnet selector terms.                                                 | `list(object({ id = optional(string) tags = optional(map(string)) }))`                                                  | `null`  |    no    |
| role                              | IAM role ARN for EC2 instances. Mutually exclusive with instance_profile.  | `string`                                                                                                                | `null`  |    no    |
| security_group_selector_terms     | List of security group selector terms with tags, ID, or name.              | `list(object({ id = optional(string) name = optional(string) tags = optional(map(string)) }))`                          | n/a     |   yes    |
| snat_policy                       | SNAT policy for the NodeClass. Valid values: Random, Disabled.             | `string`                                                                                                                | `null`  |    no    |
| subnet_selector_terms             | List of subnet selector terms with tags or ID.                             | `list(object({ id = optional(string) tags = optional(map(string)) }))`                                                  | n/a     |   yes    |
| tags                              | Custom EC2 tags to apply to instances.                                     | `map(string)`                                                                                                           | `{}`    |    no    |

### Outputs

| Name                       | Description                            |
| -------------------------- | -------------------------------------- |
| access_entry_principal_arn | Principal ARN of the EKS access entry. |
| node_class_name            | Name of the created NodeClass.         |

<!-- END_TF_DOCS -->

## License

© 2025 [Daniel Morris]\
Made available under the terms of the [MIT License].

[daniel morris]: https://unfun.co
[mit license]: ../../LICENSE.md
