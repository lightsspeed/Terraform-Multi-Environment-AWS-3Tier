# modules/database/outputs.tf

output "db_instance_endpoint" {
  description = "RDS instance endpoint (host:port)"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_address" {
  description = "RDS hostname"
  value       = aws_db_instance.main.address
}

output "db_instance_port" {
  description = "RDS port"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

# THIS IS THE ONE YOU WERE MISSING
# output "db_secret_arn" {
#   description = "ARN of the RDS master password secret (if using Secrets Manager)"
#   value       = "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:rds!db-*"
#   # If you are NOT using Secrets Manager yet, just comment it or use null:
#   # value = null
# }