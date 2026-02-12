# -----------------------------------------------------------------------------
# IAM Policy for DynamoDB Table Access
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "dynamodb_policy" {
  count = var.create_iam_policy ? 1 : 0

  statement {
    sid    = "AllowReadAccess"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable"
    ]

    resources = [
      aws_dynamodb_table.this.arn,
      "${aws_dynamodb_table.this.arn}/*"
    ]
  }

  dynamic "statement" {
    for_each = var.iam_policy_allow_write ? [1] : []
    content {
      sid    = "AllowWriteAccess"
      effect = "Allow"

      actions = [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:BatchWriteItem"
      ]

      resources = [
        aws_dynamodb_table.this.arn,
        "${aws_dynamodb_table.this.arn}/*"
      ]
    }
  }
}

resource "aws_iam_policy" "dynamodb" {
  count = var.create_iam_policy ? 1 : 0

  name        = "${local.table_name}-access-policy"
  description = "IAM policy for accessing DynamoDB table ${local.table_name}"
  policy      = data.aws_iam_policy_document.dynamodb_policy[0].json

  tags = local.common_tags
}
