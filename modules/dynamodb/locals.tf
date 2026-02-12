# =============================================================================
# Local Variables
# =============================================================================

locals {
  # Table naming
  table_name = var.table_name_prefix != "" ? "${var.table_name_prefix}-${var.table_name}" : var.table_name

  # Encryption configuration
  enable_encryption = var.kms_key_arn != null ? true : var.enable_encryption
  kms_key_arn       = var.kms_key_arn != null ? var.kms_key_arn : try(aws_kms_key.dynamodb[0].arn, null)

  # Auto scaling flags
  create_autoscaling_read  = var.billing_mode == "PROVISIONED" && var.autoscaling_enabled
  create_autoscaling_write = var.billing_mode == "PROVISIONED" && var.autoscaling_enabled

  # Tags
  common_tags = merge(
    {
      Module      = "terraform-aws-dynamodb"
      ManagedBy   = "Terraform"
      Environment = var.environment
      CostCenter  = var.cost_center
    },
    var.tags
  )

  # Backup configuration
  backup_role_arn = var.backup_iam_role_arn != "" ? var.backup_iam_role_arn : try(aws_iam_role.backup[0].arn, "")
}
