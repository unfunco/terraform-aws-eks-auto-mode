# Basic example

Creates a VPC with two public and two private subnets, and an EKS Auto Mode
cluster named `workloads` in the private subnets. The subnets carry the tags
that Auto Mode looks for when it places load balancers.

```bash
terraform init
```

```bash
terraform apply
```

```bash
aws eks update-kubeconfig --name workloads
```

A new cluster has no nodes. Auto Mode launches one when a pod needs it, which
the `inflate` deployment demonstrates:

```bash
kubectl apply -f inflate.yaml
```

```bash
kubectl get nodes --watch
```

See [Deploy a sample inflate workload] for more.

[deploy a sample inflate workload]: https://docs.aws.amazon.com/eks/latest/userguide/automode-workload.html
