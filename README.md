# AWS Infrastructure for the Application
This directory contains configurations to set up the AWS infrastructure for the application deployment. The infrastructure follows AWS best practices and implements a secure, scalable, and highly available architecture.

## Architecture Overview
The infrastructure consists of:
- VPC with public and private subnets across multiple availability zones
- Application Load Balancer (ALB) in public subnets
- EC2 instances in private subnets managed by Auto Scaling Groups
- RDS MySQL database in private subnets
- Bastion host for secure SSH access
- CloudWatch monitoring and logging

## Prerequisites
### AWS Account and Credentials
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Access key and secret key with necessary permissions

### Tools
- AWS CLI >= 2.0.0



