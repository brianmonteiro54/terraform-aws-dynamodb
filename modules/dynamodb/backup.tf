# =============================================================================
# AWS Backup Plan for DynamoDB
# =============================================================================

# -----------------------------------------------------------------------------
# IAM Role for AWS Backup
# -----------------------------------------------------------------------------
resource "aws_iam_role" "backup" {
  count = var.enable_backup_plan && var.backup_iam_role_arn == "" ? 1 : 0

  name = "${local.table_name}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  count = var.enable_backup_plan && var.backup_iam_role_arn == "" ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  count = var.enable_backup_plan && var.backup_iam_role_arn == "" ? 1 : 0

  role       = aws_iam_role.backup[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# -----------------------------------------------------------------------------
# Backup Plan
# -----------------------------------------------------------------------------
resource "aws_backup_plan" "dynamodb" {
  count = var.enable_backup_plan ? 1 : 0

  name = "${local.table_name}-backup-plan"

  rule {
    rule_name         = "${local.table_name}-daily-backup"
    target_vault_name = var.backup_vault_name
    schedule          = var.backup_schedule

    lifecycle {
      delete_after = var.backup_retention_days
    }

    recovery_point_tags = merge(
      local.common_tags,
      {
        BackupPlan = "${local.table_name}-backup-plan"
      }
    )
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Backup Selection
# -----------------------------------------------------------------------------
resource "aws_backup_selection" "dynamodb" {
  count = var.enable_backup_plan ? 1 : 0

  iam_role_arn = local.backup_role_arn
  name         = "${local.table_name}-backup-selection"
  plan_id      = aws_backup_plan.dynamodb[0].id

  resources = [
    aws_dynamodb_table.this.arn
  ]
}
