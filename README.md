cmattoon/k8s-ecr
================

Keeps ECR credentials up-to-date in non-EKS clusters.

Overview
--------

This container essentially uses one set of IAM credentials to obtain an ECR token (via `aws ecr get-login-password` and writes them to a Kubernetes Secret).

    $ helm upgrade -n portal foobar ./k8s-ecr

Should produce the following output:

```
Release "foobar" has been upgraded. Happy Helming!
NAME: foobar
LAST DEPLOYED: Sat Feb 11 23:46:59 2023
NAMESPACE: portal
STATUS: deployed
REVISION: 8
TEST SUITE: None
NOTES:
=======================================
 __ _  ____  ____      ____  ___  ____
(  / )/ _  \/ ___) ___(  __)/ __)(  _ \
 )  ( ) _  (\___ \(___)) _)( (__  )   /
(__\_)\____/(____/    (____)\___)(__\_)
0.1.0
=======================================

AWS Default Region : us-east-1
AWS Account ID     : ""

CronJob            : foobar-k8s-ecr
  ConfigMap        : foobar-k8s-ecr
  IAM Secret (in)  : foobar-k8s-ecr-iam
  ECR Secret (out) : foobar-k8s-ecr-ecr
```

It expects the IAM secret to exist at `foobar-k8s-ecr-iam` and will create the `foobar-k8s-ecr-ecr` imagePullSecret.


Configuration
-------------

| Value             | Default                    | Description                                           |
|-------------------|----------------------------|-------------------------------------------------------|
| `.aws_region`     | `us-east-1`                | The AWS region.                                       |
| `.aws_account_id` | `""`                       | If empty, retrieved from `sts get-caller-identity`.   |
| `.aws_iam_secret` | `RELEASE-NAME-k8s-ecr-iam` | The existing secret that contains IAM credentials.    |
| `.aws_ecr_secret` | `RELEASE_NAME-k8s-ecr-ecr` | The secret to which the dockerconfig will be written. |
