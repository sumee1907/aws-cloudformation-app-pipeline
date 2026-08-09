#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="config.env"

if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "ERROR: ${CONFIG_FILE} not found."
    exit 1
fi

source "${CONFIG_FILE}"

AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

S3_BUCKET="${PROJECT_NAME}-${AWS_ACCOUNT_ID}-${AWS_REGION}"
STACK_NAME="${PROJECT_NAME^^}-Main"

PACKAGED_TEMPLATE="cloudformation/main-packaged.yaml"

echo
echo "============================================================"
echo " ${PROJECT_NAME} - Deploy"
echo "============================================================"
echo
echo "AWS Region : ${AWS_REGION}"
echo "Stack Name : ${STACK_NAME}"
echo "S3 Bucket  : ${S3_BUCKET}"
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
    --parameter-overrides \
        ProjectBucketName="${S3_BUCKET}" \
        GitHubConnectionArn="${GITHUB_CONNECTION_ARN}" \
        GitHubOwner="${GITHUB_OWNER}" \
        GitHubRepository="${GITHUB_REPOSITORY}" \
        GitHubBranch="${GITHUB_BRANCH}" \
        VPCCidr="${VPC_CIDR}" \
        PublicSubnetACidr="${PUBLIC_SUBNET_A_CIDR}" \
        PublicSubnetBCidr="${PUBLIC_SUBNET_B_CIDR}" \
        PrivateSubnetACidr="${PRIVATE_SUBNET_A_CIDR}" \
        PrivateSubnetBCidr="${PRIVATE_SUBNET_B_CIDR}" \
        FrontendDesiredCount="${FRONTEND_DESIRED_COUNT}" \
        BackendDesiredCount="${BACKEND_DESIRED_COUNT}" \
        FrontendCpu="${FRONTEND_CPU}" \
        FrontendMemory="${FRONTEND_MEMORY}" \
        BackendCpu="${BACKEND_CPU}" \
        BackendMemory="${BACKEND_MEMORY}" \
        FrontendBakeTimeMinutes="${FRONTEND_BAKE_TIME_MINUTES}" \
        LogRetentionDays="${LOG_RETENTION_DAYS}" \
        ProjectName="${PROJECT_NAME}" \
        Environment="${ENVIRONMENT}" \
        ECREmptyOnDelete="${ECR_EMPTY_ON_DELETE}" \
    --no-fail-on-empty-changeset \
    --tags \
        Project=Course-End-Project \
        Environment=Course-End-Project

ALB_DNS_NAME="$(
    aws cloudformation describe-stacks \
        --stack-name "${STACK_NAME}" \
        --region "${AWS_REGION}" \
        --query "Stacks[0].Outputs[?OutputKey=='ALBDNSName'].OutputValue" \
        --output text
)"

echo
echo "Starting CodePipeline..."

PIPELINE_EXECUTION_ID="$(
    aws codepipeline start-pipeline-execution \
        --name "${PROJECT_NAME}-Pipeline" \
        --region "${AWS_REGION}" \
        --query "pipelineExecutionId" \
        --output text
)"

echo "Pipeline Execution ID: ${PIPELINE_EXECUTION_ID}"
echo "Waiting for CodePipeline to complete..."

sleep 10

while true; do

    STATUS="$(
        aws codepipeline get-pipeline-execution \
            --pipeline-name "${PROJECT_NAME}-Pipeline" \
            --pipeline-execution-id "${PIPELINE_EXECUTION_ID}" \
            --region "${AWS_REGION}" \
            --query "pipelineExecution.status" \
            --output text
    )"

    case "${STATUS}" in
        Succeeded)
            echo "Pipeline completed successfully."
            break
            ;;

        Failed|Cancelled|Stopped|Stopping)
            echo "Pipeline failed."
            exit 1
            ;;

        *)
            sleep 10
            ;;
    esac

done

echo
echo "Spining up the backend services with ${BACKEND_DESIRED_COUNT} desired count."
echo

aws ecs update-service \
    --cluster "${PROJECT_NAME}-ECS-Cluster" \
    --service "${PROJECT_NAME}-Backend-Service" \
    --desired-count "${BACKEND_DESIRED_COUNT}" \
    --region "${AWS_REGION}" \
    >/dev/null

echo
echo "Spining up the frontend services with ${FRONTEND_DESIRED_COUNT} desired count."
echo

aws ecs update-service \
    --cluster "${PROJECT_NAME}-ECS-Cluster" \
    --service "${PROJECT_NAME}-Frontend-Service" \
    --desired-count "${FRONTEND_DESIRED_COUNT}" \
    --region "${AWS_REGION}" \
    >/dev/null

echo
echo "============================================================"
echo " Deployment Complete"
echo "============================================================"
echo
echo "Stack Name      : ${STACK_NAME}"
echo "AWS Region      : ${AWS_REGION}"
echo "Application URL : http://${ALB_DNS_NAME}"
echo