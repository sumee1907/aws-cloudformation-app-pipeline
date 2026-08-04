#!/usr/bin/env bash

set -euo pipefail

STACK_NAME="CEP-Main"
AWS_REGION="us-east-1"

CFN_DIR="cloudformation"
PACKAGED_TEMPLATE="${CFN_DIR}/main-packaged.yaml"

echo
echo "============================================================"
echo " Course End Project - Deploy"
echo "============================================================"
echo
echo "AWS Region : ${AWS_REGION}"
echo "Stack Name : ${STACK_NAME}"
echo

if [[ ! -f "${PACKAGED_TEMPLATE}" ]]; then
    echo "ERROR: ${PACKAGED_TEMPLATE} does not exist."
    echo "Run ./build.sh first."
    exit 1
fi

echo "Deploying CloudFormation stack..."

aws cloudformation deploy \
    --template-file "${PACKAGED_TEMPLATE}" \
    --stack-name "${STACK_NAME}" \
    --region "${AWS_REGION}" \
    --capabilities \
        CAPABILITY_NAMED_IAM \
        CAPABILITY_AUTO_EXPAND \
    --no-fail-on-empty-changeset \
    --tags \
        Project=Course-End-Project \
        Environment=Course-End-Project

echo
echo "Deployment complete."
echo
echo "Stack outputs:"

aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --region "${AWS_REGION}" \
    --query "Stacks[0].Outputs" \
    --output table