#!/bin/bash
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:?"AWS_ACCOUNT_ID must be set"}
AWS_REGION=${AWS_DEFAULT_REGION:-"us-east-1"}
ECR_REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

K8S_SECRET_NAMESPACE=${K8S_SECRET_NAMESPACE:-"default"}
K8S_SECRET_NAME=${K8S_SECRET_NAME:-"ecr-token-${AWS_ACCOUNT_ID}-${AWS_REGION}"}
echo "ECR Repo   : ${ECR_REPO_URL}"
echo "k8s Secret : ${K8S_SECRET_NAMESPACE}/${K8S_SECRET_NAME}"

echo "Attempting to obtain ECR token for ${ECR_REPO_URL} in ${REGION}"

ECR_TOKEN=$(aws ecr get-login-password --region $AWS_REGION | base64 -d)
if [ -z "$ECR_TOKEN" ]; then
    >&2 echo "Error: get-login-password returned an empty result!"
    exit 1;
fi
echo "Writing ECR token for ${ECR_REPO_URL} to ${K8S_SECRET_NAMESPACE}/${K8S_SECRET_NAME}"
kubectl --namespace "$K8S_SECRET_NAMESPACE" \
	create secret docker-registry "$K8S_SECRET_NAME" \
	--docker-server="${ECR_REPO_URL}" \
	--docker-username=AWS \
	--docker-password="$ECR_TOKEN"
ECR_TOKEN=$( aws ecr get-authorization-token  | jq -r '.authorizationData[].authorizationToken' | base64 -D | cut -d: -f2)
