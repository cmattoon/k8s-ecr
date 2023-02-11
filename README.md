cmattoon/k8s-ecr
================

Keeps ECR credentials up-to-date in non-EKS clusters.

Overview
--------

This container essentially uses one set of IAM credentials to obtain an ECR token (via `aws ecr get-login-password` and writes them to a Kubernetes Secret).

This means the container needs:

  1. A valid set of AWS credentials
  2. Appropriate RBAC access to Get, Create, or Update the Secret.

Configuration
-------------

  1. The default credential provider chain is used to make the `aws-cli` call, meaning you can provide the IAM credentials via the environment (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) or by mounting a credential file at `/root/.aws/credentials`.
  2. The `AWS_ACCOUNT_ID` is required to build the ECR repository ARN/URL.
  3. If no `AWS_REGION` is specified, `AWS_DEFAULT_REGION` will be used; else, `us-east-1`.
  5. The auth token obtained from the `aws-cli` call will be written to `${K8S_SECRET_NAMESPACE}/${K8S_SECRET_NAME}`
  6. If no `K8S_SECRET_NAME` is set, ECR tokens are written to `default/ecr-token-${AWS_ACCOUNT_ID}-${AWS_REGION}`


Deployment
----------

This image is best deployed as a `CronJob` running at least as often as your ECR credentials expire (default: `12h`).

First, deploy your long-lived AWS credentials:

#### Example Environment Secrets File
```
---
apiVersion: v1
kind: Secret
metadata:
  name: example-env
stringData:
  AWS_ACCESS_KEY_ID: "<YOUR ACCESS KEY>"
  AWS_SECRET_ACCESS_KEY: "<YOUR SECRET KEY>"
  AWS_DEFAULT_REGION: "us-east-1"
```

#### Example AWS Credentials File
```
---
apiVersion: v1
kind: Secret
metadata:
  name: example-config-files
stringData:
  credentials: |
    [default]
	aws_access_key_id = <YOUR ACCESS KEY>
	aws_secret_access_key = <YOUR_SECRET_KEY>
```

