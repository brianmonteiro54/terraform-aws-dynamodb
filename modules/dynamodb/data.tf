data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# KMS Policy Document (Least Privilege)
# -----------------------------------------------------------------------------
data "aws_iam_policy_document" "kms" {
  # checkov:skip=CKV_AWS_356: Root permissions required by AWS KMS key policy
  # checkov:skip=CKV_AWS_111: Root permissions required by AWS KMS key policy
  # checkov:skip=CKV_AWS_109: Root permissions required by AWS KMS key policy

  statement {
    sid    = "EnableRootPermissions"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowDynamoDBUsage"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["dynamodb.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values = [
        "dynamodb.${data.aws_region.current.id}.amazonaws.com"
      ]
    }
  }
}
