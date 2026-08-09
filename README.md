# AWS CloudFormation App Pipeline

An Infrastructure as Code (IaC) project that deploys a containerized React frontend and Node.js backend to Amazon ECS using AWS CloudFormation. The project provisions the complete AWS environment, builds Docker images, deploys the application, and creates a CI/CD pipeline for future application updates.

## What This Project Does

This project automatically creates an AWS environment capable of hosting a modern containerized web application.

A single deployment will:

* Store CloudFormation templates in Amazon S3.
* Create the networking infrastructure.
* Create Amazon ECR repositories.
* Provision an Amazon ECS Fargate cluster.
* Create a complete CI/CD pipeline using CodePipeline and CodeBuild.
* Configure logging with Amazon CloudWatch.
* Configure secure communication between services using ECS Service Connect.
* Deploy a public React frontend.
* Deploy a private Node.js backend.
* Deploy the application behind an Application Load Balancer.

After deployment, pushing code to the configured GitHub repository automatically rebuilds and redeploys the application.

---

## AWS Services Used

* AWS CloudFormation (Nested Stacks)
* Amazon VPC
* Amazon ECS (Fargate)
* Amazon ECR
* AWS CodePipeline
* AWS CodeBuild
* AWS CodeConnections
* Application Load Balancer (ALB)
* Amazon CloudWatch Logs
* Amazon S3
* AWS IAM

---

## Solution

This project demonstrates a complete production-style deployment pipeline using Infrastructure as Code.

Rather than manually creating AWS resources through the console, the entire environment is deployed from source control using CloudFormation.

The solution provides:

* Repeatable deployments
* Automated application builds
* Automated Docker image management
* Automated ECS deployments
* Isolated frontend and backend services
* Secure service-to-service communication
* Consistent infrastructure across environments
* One-command deployment and teardown

---

## Deploying Your Own Copy

1. Fork this repository.
2. Create an [AWS CodeConnections](https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-create.html) connection to your GitHub repository.
3. Update `config.env` with your AWS account and GitHub information.
4. Build the CloudFormation package.

```bash
./build.sh
```

5. Deploy the infrastructure.

```bash
./deploy.sh
```

6. Access the application using the URL displayed at the end of the deployment.

---

## Configuration

All user-configurable settings are located in `config.env`.

| Parameter             | Required | Description                                                          |
| --------------------- | -------- | -------------------------------------------------------------------- |
| AWS Region            | Yes      | AWS region where all resources will be deployed.                     |
| GitHub Owner          | Yes      | GitHub username or organization.                                     |
| GitHub Repository     | Yes      | Repository containing the application source.                        |
| GitHub Branch         | Yes      | Branch monitored by CodePipeline.                                    |
| GitHub Connection ARN | Yes      | AWS CodeConnections ARN used to connect GitHub to CodePipeline.      |
| Project Name          | Yes      | Prefix used when naming AWS resources.                               |
| Environment           | Yes      | Environment name (for example: `dev`, `test`, `prod`).               |
| VPC Network           | No       | CIDR blocks for the VPC and subnets.                                 |
| ECS CPU & Memory      | No       | CPU and memory allocated to each ECS task.                           |
| ECS Desired Count     | No       | Number of running tasks for each ECS service.                        |
| Log Retention         | No       | CloudWatch log retention period.                                     |
| ECR Cleanup           | No       | Controls whether ECR repositories are emptied during stack deletion. |
| S3 Cleanup            | No       | Controls whether the deployment S3 bucket is deleted during cleanup. |

The default values are suitable for most deployments. Only the required settings must be changed.

---

## Customizing the Project

This project is intended to be used as a starting point for your own containerized applications.

Common customizations include:

* Replace the sample React frontend.
* Replace the sample Node.js backend.
* Modify the VPC network configuration.
* Adjust ECS CPU, memory, and scaling values.
* Add additional ECS services.
* Extend the CI/CD pipeline with additional testing or security scanning.
* Add Route 53 and ACM for custom domains and HTTPS.
* Add CloudFront, WAF, or ECS Auto Scaling.

---

## Cleanup

To remove all deployed resources:

```bash
./destroy.sh
```

Cleanup behavior is controlled through `config.env`, allowing you to choose whether the Amazon ECR repositories and Amazon S3 deployment bucket are retained or deleted.

---

## License

This project is provided as a learning reference and may be modified for your own AWS container deployments.
