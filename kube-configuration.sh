#!/bin/bash

### Setup permissions on local kubectl (You need to use the same IAM user used to create the EKS cluster)
mkdir $HOME/.kube
cp ./templates/config-k8s $HOME/.kube/config
sed -i -e "s#<endpoint-url>#$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query cluster.endpoint --output text)#g" $HOME/.kube/config
sed -i -e "s#<base64-encoded-ca-cert>#$(aws eks describe-cluster --name $EKS_CLUSTER_NAME --query cluster.certificateAuthority.data --output text)#g" $HOME/.kube/config
sed -i -e "s#<cluster-name>#$EKS_CLUSTER_NAME#g" $HOME/.kube/config

### Setup permission for nodes to connect to EKS master
cp ./templates/aws-auth-cm.yml aws-auth-cm-tmp.yml
export EKS_WORKER_ROLE=$(aws cloudformation describe-stacks --stack-name $EKS_CLUSTER_NAME | jq -r '.Stacks[0].Outputs[]|select(.OutputKey=="NodeInstanceRole")|.OutputValue')
sed -i -e "s#<ARN of instance role (not instance profile)>#${EKS_WORKER_ROLE}#g" aws-auth-cm-tmp.yml
kubectl apply -f aws-auth-cm-tmp.yml
rm aws-auth-cm-tmp.yml