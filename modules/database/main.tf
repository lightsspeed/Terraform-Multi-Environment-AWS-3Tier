# modules/database/main.tf

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# RDS Parameter Group (optional but good practice)
resource "aws_db_parameter_group" "main" {
  name   = "${var.environment}-db-params"
  family = "postgres15" # Change to mysql8.0, aurora-postgresql15, etc. as needed

  parameter {
    name  = "log_connections"
    value = "1"
  }

  tags = {
    Environment = var.environment
  }
}

# RDS Instance (PostgreSQL by default — change engine if needed)
resource "aws_db_instance" "main" {
  identifier            = "${var.environment}-db"
  engine                = "postgres"
  engine_version        = "15"
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_allocated_storage * 5 # Auto-scaling storage
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [var.db_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = aws_db_parameter_group.main.name

  multi_az                  = var.enable_multi_az
  publicly_accessible       = false
  backup_retention_period   = var.backup_retention_period
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "${var.environment}-db-final-snapshot"

  performance_insights_enabled = true

  tags = {
    Name        = "${var.environment}-db"
    Environment = var.environment
  }
}
