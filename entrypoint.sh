#!/bin/bash
# Entrypoint script.
#
# Given an "IAM_SECRET_NAMESPACE/IAM_SECRET_NAME" containing AWS_ACCESS_KEY/AWS_SECRET_KEY
# (or the AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY vars are set),
# attempts to get an authorization token from AWS and creates/updates 
# the Kubernetes secret at "ECR_SECRET_NAMESPACE/ECR_SECRET".
#

_CURRENT_NS="default"
if [ -f /var/run/secrets/kubernetes.io/serviceaccount/namespace ]; then
    _CURRENT_NS=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
fi
echo "Using a default namespace of '${_CURRENT_NS}'"

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "ERROR: AWS_ACCESS_KEY_ID is empty."
    exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "ERROR: AWS_SECRET_ACCESS_KEY is empty."
    exit 1
fi

AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"us-east-1"}
echo "Using default region '${AWS_DEFAULT_REGION}'"

AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-""}
if [ -z "$AWS_ACCOUNT_ID" ]; then
   echo "AWS_ACCOUNT_ID is not set."
   accountId=$(aws sts get-caller-identity | jq -r '.Account' 2>&1)
   if [ -z "$accountId" ]; then
       echo "ERROR: AWS_ACCOUNT_ID is not set and a call to 'sts get-caller-identity' failed"
       exit 1
   fi
   echo "Setting AWS_ACCOUNT_ID to ${accountId}"
   export AWS_ACCOUNT_ID="$accountId"
fi

ECR_REPO_URL="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
echo "Authenticating to ECR repository at ${ECR_REPO_URL} as ${AWS_ACCESS_KEY_ID}"
#ECR_TOKEN=$( aws ecr get-authorization-token  | jq -r '.authorizationData[].authorizationToken' | base64 -D | cut -d: -f2)
ECR_TOKEN=$(aws ecr get-login-password --region $AWS_REGION | base64 -d)
if [ -z "$ECR_TOKEN" ]; then
    >&2 echo "Error: get-login-password returned an empty result!"
    exit 1;
fi

ECR_SECRET_NAMESPACE=${ECR_SECRET_NAMESPACE:-"${CURRENT_NS}"}
ECR_SECRET_NAME=${ECR_SECRET_NAME:-"ecr-token-${AWS_ACCOUNT_ID}-${AWS_REGION}"}

echo "Writing ECR token for ${ECR_REPO_URL} to ${ECR_SECRET_NAMESPACE}/${ECR_SECRET_NAME}"
kubectl --namespace "${ECR_SECRET_NAMESPACE}" \
	create secret docker-registry "${ECR_SECRET_NAME}" \
	--docker-server="${ECR_REPO_URL}" \
	--docker-username=AWS \
	--docker-password="${ECR_TOKEN}"

