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

| Name         | Description                                                                                                       | Type          | Default | Required |
| ------------ | ----------------------------------------------------------------------------------------------------------------- | ------------- | ------- | :------: |
| cluster_name | Name of the EKS cluster the pipeline deploys, as passed to the root module.                                       | `string`      | n/a     |   yes    |
| kms_key_arns | ARNs of the KMS keys passed to the root module, which the pipeline must be able to describe and create grants on. | `set(string)` | `[]`    |    no    |

### Outputs

| Name | Description                                                                                 |
| ---- | ------------------------------------------------------------------------------------------- |
| json | IAM policy document, as JSON, that grants the permissions needed to deploy the root module. |

<!-- END_TF_DOCS -->
