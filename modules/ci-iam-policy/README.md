# IAM policy for CI/CD pipelines

<!-- BEGIN_TF_DOCS -->

### Resources

| Name                                                                                                                               | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)         | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition)                     | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                           | data source |

### Inputs

| Name         | Description                                   | Type     | Default | Required |
| ------------ | --------------------------------------------- | -------- | ------- | :------: |
| cluster_name | Cluster name.                                 | `string` | n/a     |   yes    |
| create       | Enable/disable the creation of all resources. | `bool`   | `true`  |    no    |

### Outputs

| Name            | Description                                                                     |
| --------------- | ------------------------------------------------------------------------------- |
| policy_document | IAM policy document granting least-privilege permissions to deploy this module. |

<!-- END_TF_DOCS -->
