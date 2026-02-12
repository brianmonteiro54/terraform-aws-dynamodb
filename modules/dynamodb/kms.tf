resource "aws_kms_key" "dynamodb" {
  count = (var.kms_key_arn == null && var.enable_encryption && var.create_kms_key) ? 1 : 0

  description             = "KMS key for DynamoDB table ${local.table_name}"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = var.enable_multi_region

  policy = data.aws_iam_policy_document.kms.json

  tags = merge(
    local.common_tags,
    { Name = "${local.table_name}-kms-key" }
  )
}

resource "aws_kms_alias" "dynamodb" {
  count = (var.kms_key_arn == null && var.enable_encryption && var.create_kms_key) ? 1 : 0

  name          = "alias/${local.table_name}"
  target_key_id = aws_kms_key.dynamodb[0].key_id
}
