# modules/database/variables.tf   ← COPY-PASTE THIS ENTIRE FILE

variable "environment" {
  type        = string
  description = "Environment name (dev/staging/prod)"
}

variable "private_db_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for RDS"
}

variable "db_security_group_id" {
  type        = string
  description = "Security group ID for RDS"
}

variable "db_name" {
  type        = string
  description = "Initial database name"
}

variable "db_instance_class" {
  type        = string
  default     = "db.t3.micro"
  description = "RDS instance class"
}

variable "db_allocated_storage" {
  type        = number
  default     = 20
  description = "Initial allocated storage in GB"
}

variable "db_username" {
  type        = string
  description = "Master username"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Master password"
  sensitive   = true
}

variable "enable_multi_az" {
  type        = bool
  default     = false
  description = "Enable Multi-AZ deployment"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "Number of days to retain automated backups"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip final snapshot on destroy (set false in prod)"
}
