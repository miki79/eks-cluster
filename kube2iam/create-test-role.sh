#!/bin/bash
DIR=`dirname "$0"`
cp $DIR/trust-role.json trust-role-tmp.json
export EKS_WORKER_ROLE=$(aws cloudformation describe-stacks --stack-name $EKS_CLUSTER_NAME | jq -r '.Stacks[0].Outputs[]|select(.OutputKey=="NodeInstanceRole")|.OutputValue')
sed -i -e "s#<NodeIAMRoleARN>#${EKS_WORKER_ROLE}#g" trust-role-tmp.json
aws iam create-role --role-name eks_subrole --assume-role-policy-document file://trust-role-tmp.json
aws iam attach-role-policy --role-name eks_subrole --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
rm trust-role-tmp.json
kubectl create -f $DIR/test-pod.yml