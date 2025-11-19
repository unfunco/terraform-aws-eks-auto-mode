# Basic example

Creates a three-AZ VPC with public and private subnets, provisions an
auto mode EKS cluster named `workloads-sandbox`, and tags the subnets for
load balancers and pods.

Try it out:

1. `terraform init` && `terraform apply`
2. `aws eks update-kubeconfig --name workloads-sandbox --region us-west-2`
3. `kubectl apply -f inflate.yaml` to schedule a placeholder pod using auto mode

Reference: https://docs.aws.amazon.com/eks/latest/userguide/automode-workload.html
