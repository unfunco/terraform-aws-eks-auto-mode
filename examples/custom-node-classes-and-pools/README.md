# Custom NodePools and NodeClasses example

Builds a dev EKS Auto Mode cluster with:

- Public/private subnets for the control plane and nodes.
- Dedicated intra-subnets for pod ENIs selected by the NodeClass.
- FIPS-enabled NodeClass with 200Gi ephemeral storage and pod security groups.
- Custom NodePool pinned to arm64/amd64 in specific AZs with disruption budgets.

Run `terraform init` && `terraform apply`, then:

1. `aws eks update-kubeconfig --name workloads --region us-west-2`
2. Verify the NodeClass with `kubectl get nodeclasses`
3. Verify the NodePool with `kubectl get nodepools`
