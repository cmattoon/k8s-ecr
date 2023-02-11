FROM alpine/k8s:1.25.6

ENV AWS_ACCOUNT_ID       ""
ENV AWS_DEFAULT_REGION   ""
ENV K8S_SECRET_NAME      ""
ENV K8S_SECRET_NAMESPACE "default"

WORKDIR /app

COPY ecr-login.sh .

RUN chmod +x ecr-login.sh

ENTRYPOINT ["/app/ecr-login.sh"]
