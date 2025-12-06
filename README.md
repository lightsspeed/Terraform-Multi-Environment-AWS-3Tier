# Terraform Multi-Environment AWS 3-Tier Architecture

A production-ready Infrastructure as Code (IaC) solution for deploying a 3-tier application architecture across multiple environments (dev, staging, production) on AWS using Terraform and GitHub Actions.

## 🏗️ Architecture Overview

This project implements a scalable 3-tier architecture:

- **Presentation Tier**: Application Load Balancer (ALB) + Auto Scaling Group
- **Application Tier**: EC2 instances in private subnets with Auto Scaling
- **Data Tier**: RDS PostgreSQL with Multi-AZ deployment (staging/prod)

### Infrastructure Components

- VPC with public and private subnets across multiple AZs
- Internet Gateway and NAT Gateways for network connectivity
- Security Groups with least privilege access
- Application Load Balancer for traffic distribution
- Auto Scaling Groups for high availability
- RDS PostgreSQL database with automated backups
- S3 bucket for Terraform state management
- CloudWatch for monitoring and logging

## 📁 Project Structure

```
Terraform-Multi-Environment-AWS-3Tier/
├── .github/
│   └── workflows/
│       ├── terraform-dev.yml
│       ├── terraform-staging.yml
│       └── terraform-prod.yml
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── main.tf
│       ├── terraform.tfvars
│       └── backend.tf
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── database/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── security/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── scripts/
│   └── user-data.sh
├── .gitignore
└── README.md
```

## 🚀 Getting Started

### Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured
- GitHub repository with Actions enabled

### AWS Credentials Setup

1. Create an IAM user with programmatic access
2. Attach necessary policies (VPC, EC2, RDS, S3, IAM)
3. Store credentials as GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

### S3 Backend Setup

Create S3 buckets for Terraform state:

```bash
aws s3api create-bucket \
  --bucket terraform-state-dev-your-unique-id \
  --region us-east-1

aws s3api create-bucket \
  --bucket terraform-state-staging-your-unique-id \
  --region us-east-1

aws s3api create-bucket \
  --bucket terraform-state-prod-your-unique-id \
  --region us-east-1
```

Enable versioning:

```bash
aws s3api put-bucket-versioning \
  --bucket terraform-state-dev-your-unique-id \
  --versioning-configuration Status=Enabled
```

## 🔧 Configuration

### Environment-Specific Variables

Each environment has its own `terraform.tfvars` file:

**Dev Environment** (`environments/dev/terraform.tfvars`):

- Smaller instance types (t3.micro)
- Single AZ RDS
- Minimal Auto Scaling (1-2 instances)

**Staging Environment** (`environments/staging/terraform.tfvars`):

- Medium instance types (t3.small)
- Multi-AZ RDS
- Moderate Auto Scaling (2-4 instances)

**Production Environment** (`environments/prod/terraform.tfvars`):

- Production instance types (t3.medium+)
- Multi-AZ RDS with read replicas
- Robust Auto Scaling (3-10 instances)

## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

Three separate workflows for each environment:

1. **terraform-dev.yml**: Triggered on push to `develop` branch
2. **terraform-staging.yml**: Triggered on push to `staging` branch
3. **terraform-prod.yml**: Triggered on push to `main` branch (requires approval)

### Workflow Steps

1. Checkout code
2. Configure AWS credentials
3. Setup Terraform
4. Terraform Init
5. Terraform Plan
6. Terraform Apply (with manual approval for prod)

## 📝 Usage

### Local Development

```bash
# Navigate to environment directory
cd environments/dev

# Initialize Terraform
terraform init

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Via GitHub Actions

1. Push to `develop` branch → Deploys to Dev
2. Push to `staging` branch → Deploys to Staging
3. Push to `main` branch → Requires approval → Deploys to Prod

## 🔒 Security Best Practices

- All sensitive data stored in AWS Secrets Manager
- Security Groups follow least privilege principle
- Database credentials rotated automatically
- Private subnets for application and database tiers
- WAF rules for ALB (optional, can be enabled)
- Encryption at rest for RDS and EBS volumes
- VPC Flow Logs enabled for network monitoring

## 📊 Monitoring

- CloudWatch alarms for CPU, memory, and disk usage
- ALB health checks for application availability
- RDS performance insights enabled
- Custom metrics for application monitoring

## 🔍 Troubleshooting

### Common Issues

**State Lock Error**:

```bash
terraform force-unlock <lock-id>
```

**Module Not Found**:

```bash
terraform get -update
```

**AWS Credentials**:

```bash
aws sts get-caller-identity
```

## 🤝 Contributing

1. Create feature branch from `develop`
2. Make changes and test locally
3. Submit PR with description
4. Wait for CI checks to pass
5. Request review from team

## 📜 License

MIT License - feel free to use this project for your own infrastructure needs.

## 📞 Support

For issues and questions:

- Open a GitHub issue
- Check existing documentation
- Review AWS CloudWatch logs

## 🔄 Versioning

We use semantic versioning for infrastructure changes:

- MAJOR: Breaking changes
- MINOR: New features
- PATCH: Bug fixes

Current Version: 1.0.0
