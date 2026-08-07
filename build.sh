#!/usr/bin/env bash

set -euo pipefail

PROJECT_NAME="cep"
AWS_REGION="us-east-1"

CFN_DIR="cloudformation"
MAIN_TEMPLATE="${CFN_DIR}/main.yaml"
PACKAGED_TEMPLATE="${CFN_DIR}/main-packaged.yaml"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
S3_BUCKET="${PROJECT_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}"

echo "Building Course End Project"
echo "Region: ${AWS_REGION}"
echo "Bucket: ${S3_BUCKET}"
echo

# Create S3 bucket if it doesn't exist
if ! aws s3api head-bucket --bucket "${S3_BUCKET}" 2>/dev/null; then
    echo "Creating S3 bucket..."

    aws s3api create-bucket \
        --bucket "${S3_BUCKET}" \
        --region "${AWS_REGION}" \
        >/dev/null
fi

# Enable server-side encryption and block public access
aws s3api put-bucket-encryption \
    --bucket "${S3_BUCKET}" \
    --server-side-encryption-configuration \
    '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block \
    --bucket "${S3_BUCKET}" \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Validating templates..."

# Validate each CloudFormation stack template
for template in network.yaml ecr.yaml main.yaml iam.yaml ecs.yaml codebuild.yaml; do
    aws cloudformation validate-template \
        --template-body "file://${CFN_DIR}/${template}" \
        --region "${AWS_REGION}" \
        >/dev/null

    echo "${template} is valid."
done

echo "Removing old packaged templates..."

aws s3 rm \
    "s3://${S3_BUCKET}/cloudformation/templates/" \
    --recursive

echo "Packaging templates..."

# Packaging the main CloudFormation template and uploading it as an artifact to the S3 bucket
aws cloudformation package \
    --template-file "${MAIN_TEMPLATE}" \
    --s3-bucket "${S3_BUCKET}" \
    --s3-prefix cloudformation/templates \
    --output-template-file "${PACKAGED_TEMPLATE}" \
    --region "${AWS_REGION}"

echo
echo "Build complete."
echo "Next: ./deploy.sh"