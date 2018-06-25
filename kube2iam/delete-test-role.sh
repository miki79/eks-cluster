#!/bin/bash
DIR=`dirname "$0"`
aws iam detach-role-policy --role-name eks_subrole --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
aws iam delete-role --role-name eks_subrole
kubectl delete -f $DIR/test-pod.yml