# =============================================================================
# Outputs - DynamoDB Module
# =============================================================================

# -----------------------------------------------------------------------------
# Table Information
# -----------------------------------------------------------------------------
output "table_id" {
  description = "ID/Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}

output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "table_stream_arn" {
  description = "ARN of the DynamoDB table stream (if enabled)"
  value       = try(aws_dynamodb_table.this.stream_arn, null)
}

output "table_stream_label" {
  description = "Timestamp of the DynamoDB table stream (if enabled)"
  value       = try(aws_dynamodb_table.this.stream_label, null)
}

# -----------------------------------------------------------------------------
# Encryption Information
# -----------------------------------------------------------------------------
output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = var.kms_key_arn != null ? var.kms_key_arn : try(aws_kms_key.dynamodb[0].id, null)
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = var.kms_key_arn != null ? var.kms_key_arn : try(aws_kms_key.dynamodb[0].arn, null)
}

output "kms_key_alias" {
  description = "Alias of the KMS key used for encryption"
  value       = try(aws_kms_alias.dynamodb[0].name, null)
}

# -----------------------------------------------------------------------------
# Auto Scaling Information
# -----------------------------------------------------------------------------
output "autoscaling_read_target_arn" {
  description = "ARN of the read capacity autoscaling target"
  value       = try(aws_appautoscaling_target.dynamodb_table_read[0].arn, null)
}

output "autoscaling_write_target_arn" {
  description = "ARN of the write capacity autoscaling target"
  value       = try(aws_appautoscaling_target.dynamodb_table_write[0].arn, null)
}

output "autoscaling_read_policy_arn" {
  description = "ARN of the read capacity autoscaling policy"
  value       = try(aws_appautoscaling_policy.dynamodb_table_read_policy[0].arn, null)
}

output "autoscaling_write_policy_arn" {
  description = "ARN of the write capacity autoscaling policy"
  value       = try(aws_appautoscaling_policy.dynamodb_table_write_policy[0].arn, null)
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms
# -----------------------------------------------------------------------------
output "alarm_read_throttle_arn" {
  description = "ARN of the read throttle events alarm"
  value       = try(aws_cloudwatch_metric_alarm.read_throttle_events[0].arn, null)
}

output "alarm_write_throttle_arn" {
  description = "ARN of the write throttle events alarm"
  value       = try(aws_cloudwatch_metric_alarm.write_throttle_events[0].arn, null)
}

output "alarm_user_errors_arn" {
  description = "ARN of the user errors alarm"
  value       = try(aws_cloudwatch_metric_alarm.user_errors[0].arn, null)
}

# -----------------------------------------------------------------------------
# Backup Information
# -----------------------------------------------------------------------------
output "backup_plan_id" {
  description = "ID of the AWS Backup plan"
  value       = try(aws_backup_plan.dynamodb[0].id, null)
}

output "backup_plan_arn" {
  description = "ARN of the AWS Backup plan"
  value       = try(aws_backup_plan.dynamodb[0].arn, null)
}

output "backup_selection_id" {
  description = "ID of the backup selection"
  value       = try(aws_backup_selection.dynamodb[0].id, null)
}

# -----------------------------------------------------------------------------
# IAM Policy Information
# -----------------------------------------------------------------------------
output "iam_policy_arn" {
  description = "ARN of the IAM policy for table access"
  value       = try(aws_iam_policy.dynamodb[0].arn, null)
}

output "iam_policy_id" {
  description = "ID of the IAM policy for table access"
  value       = try(aws_iam_policy.dynamodb[0].id, null)
}

output "iam_policy_name" {
  description = "Name of the IAM policy for table access"
  value       = try(aws_iam_policy.dynamodb[0].name, null)
}

# -----------------------------------------------------------------------------
# Configuration Information (for reference)
# -----------------------------------------------------------------------------
output "table_configuration" {
  description = "Complete table configuration for reference"
  value = {
    table_name                  = aws_dynamodb_table.this.name
    billing_mode                = aws_dynamodb_table.this.billing_mode
    hash_key                    = aws_dynamodb_table.this.hash_key
    range_key                   = aws_dynamodb_table.this.range_key
    stream_enabled              = aws_dynamodb_table.this.stream_enabled
    stream_view_type            = aws_dynamodb_table.this.stream_view_type
    encryption_enabled          = local.enable_encryption
    point_in_time_recovery      = var.point_in_time_recovery_enabled
    deletion_protection_enabled = var.deletion_protection_enabled
    ttl_enabled                 = var.ttl_enabled
    table_class                 = aws_dynamodb_table.this.table_class
  }
}

# -----------------------------------------------------------------------------
# Sensitive Outputs (Optional - Mark as sensitive if needed)
# -----------------------------------------------------------------------------
output "table_attributes" {
  description = "List of all table attributes"
  value       = var.attributes
  sensitive   = false
}

output "global_secondary_indexes" {
  description = "List of global secondary indexes"
  value       = var.global_secondary_indexes
  sensitive   = false
}

output "local_secondary_indexes" {
  description = "List of local secondary indexes"
  value       = var.local_secondary_indexes
  sensitive   = false
}
