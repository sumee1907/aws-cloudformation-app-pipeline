#!/usr/bin/env bash

set -euo pipefail

PROJECT_NAME="cep"
STACK_NAME="CEP-Main"
AWS_REGION="us-east-1"

AWS_ACCOUNT_ID="$(
    aws sts get-caller-identity \
        --query Account \
        --output text
)"

S3_BUCKET="${PROJECT_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}"

echo
echo "============================================================"
echo " Course End Project - Destroy"
echo "============================================================"
echo
echo "AWS Region : ${AWS_REGION}"
echo "Stack Name : ${STACK_NAME}"
echo "S3 Bucket  : ${S3_BUCKET}"
echo

if aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${AWS_REGION}" \
    >/dev/null 2>&1; then

    echo "Deleting CloudFormation stack..."

    aws cloudformation delete-stack \
        --stack-name "${STACK_NAME}" \
        --region "${AWS_REGION}"

    echo "Waiting for stack deletion to complete..."

    aws cloudformation wait stack-delete-complete \
        --stack-name "${STACK_NAME}" \
        --region "${AWS_REGION}"

    echo "CloudFormation stack deleted."
else
    echo "CloudFormation stack does not exist."
fi

echo

if aws s3api head-bucket \
    --bucket "${S3_BUCKET}" \
    2>/dev/null; then

    echo "Deleting S3 bucket and all data inside..."

    aws s3 rb "s3://${S3_BUCKET}" \
        --force \
        --region "${AWS_REGION}"

    echo "S3 bucket deleted."
else
    echo "S3 bucket does not exist."
fi

rm -f cloudformation/main-packaged.yaml

echo
echo "Destroy complete."