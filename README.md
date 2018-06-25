# EKS cloudformation template

Set of templates and scripts to easily setup an Amazon EKS cluster with multiple nodes, authentications for kubectl and kube2iam.

[Cloudformation template](templates/amazon-eks-vpc.yml) generates a VPC, 3 subnets, 1 EKS cluster and 3 nodes.

List parameters cloudformation template:

- ClusterName: EKS cluster name
- KeyName: name key pair for EC2 (default: none)
- NodeAutoScalingGroupMaxSize: maximum number of nodes (default: 3)
- NodeAutoScalingGroupMinSize: minimum number of nodes (default: 1)
- NodeInstanceType: node instance type (default: t2.medium)
- Subnet01Block: IP block first subnet (default 192.168.64.0/18)
- Subnet02Block: IP block first subnet (default 192.168.128.0/18)
- Subnet03Block: IP block first subnet (default 192.168.192.0/18)
- VpcBlock: (default 192.168.0.0/16)

## Set up Environment:

### Tools

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Environmental variables

- AWS_DEFAULT_REGION: region where to deploy the cluster, possible regions are us-west-2,us-east-1 (required)
- EKS_CLUSTER_NAME: stack and cluster name (required)
- KEY_PAIR: name key pair already present in the region selected (optional)

## Launch Cluster

```
aws cloudformation deploy --template-file templates/amazon-eks-vpc.yml --stack-name $EKS_CLUSTER_NAME --parameter-overrides ClusterName=$EKS_CLUSTER_NAME KeyName=$KEY_PAIR --capabilities CAPABILITY_IAM
```

Average time to deploy: 10 minutes

### Setup permissions

Setup local configuration for kubectl and permission for worker nodes to join cluster (**_ATTENTION: this command overwrite the file ~/.kube/config_**)
`./kube-configuration.sh`

You need to run this script, you need to use the same IAM user used to create the EKS cluster, otherwise kubectl cannot connect to the cluster. [more info on EKS permission](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)
The second part of the scripts, set the permission for the IAM role associated to the worker nodes to join the EKS cluster.

#### Verify that everything is working correctly

Connect to the remote k8s cluster:

```
kubectl get svc
```

Check if the nodes are connected:

```
kubectl get no
```

### (Optional) Install [Kube2IAM](https://github.com/jtblin/kube2iam)

Add daemonset kube2iam and related permissions

```
kubectl apply -f templates/kube2iam-ds.yml
```

Please note:
The IAM role assigned to the worker node has the permission to assume only roles with the name starting with eks\_
To modify this restriction, change the [amazon-eks-vpc.yml](templates/amazon-eks-vpc.yml#L515)

#### Test Kube2IAM

To verify if kube2iam is working correctly, this script creates a new role named "eks_subrole", adds policy to read S3, creates a [test pod](kube2iam/test-pod.yml)

```
kube2iam/create-test-role.sh
```

Run the command

```
kubectl exec -it aws-cli aws s3 ls
```

#### Clean up kube2iam test

```
kube2iam/delete-test-role.sh
```

## Clean up cluster

```
aws cloudformation delete-stack --stack-name $EKS_CLUSTER_NAME
```

## References:

- [Getting Started with Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html)
- [Kube2IAM](https://github.com/jtblin/kube2iam)
- [Network interface Kube2iam and EKS](https://github.com/jtblin/kube2iam/pull/146)
- [Amazon EKS authentication](https://docs.aws.amazon.com/eks/latest/userguide/managing-auth.html)
- [Install dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html)
- [Amazon EKS workshop](https://github.com/aws-samples/aws-workshop-for-kubernetes)

### TODO:

- add [external DNS](https://github.com/kubernetes-incubator/external-dns/blob/master/docs/tutorials/aws-sd.md) instruction
- add template for Terraform
