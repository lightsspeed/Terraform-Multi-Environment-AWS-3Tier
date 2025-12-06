terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  enable_nat_gateway       = true
  enable_flow_logs         = true
}

# Security Module
module "security" {
  source = "../../modules/security"

  environment = var.environment
  vpc_id      = module.networking.vpc_id
  app_port    = 8080
}

# Compute Module
module "compute" {
  source = "../../modules/compute"

  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  alb_security_group_id  = module.security.alb_security_group_id
  app_security_group_id  = module.security.app_security_group_id
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  asg_min_size           = var.asg_min_size
  asg_max_size           = var.asg_max_size
  asg_desired_capacity   = var.asg_desired_capacity
  app_port               = 8080
  health_check_path      = "/health"
  root_volume_size       = 50
}

# Database Module
module "database" {
  source = "../../modules/database"

  environment                 = var.environment
  private_db_subnet_ids       = module.networking.private_db_subnet_ids
  db_security_group_id        = module.security.db_security_group_id
  db_name                     = var.db_name
  db_instance_class           = var.db_instance_class
  db_allocated_storage        = var.db_allocated_storage
  db_max_allocated_storage    = 500
  enable_multi_az             = true # Multi-AZ for production
  backup_retention_period     = 30
  enable_performance_insights = true
}

# Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "db_secret_arn" {
  description = "ARN of the database credentials secret"
  value       = module.database.db_secret_arn
}
