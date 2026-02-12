# =============================================================================
# DynamoDB Table
# =============================================================================

resource "aws_dynamodb_table" "this" {
  name             = local.table_name
  billing_mode     = var.billing_mode
  hash_key         = var.hash_key
  range_key        = var.range_key
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null
  table_class      = var.table_class

  # Provisioned throughput (only if billing_mode is PROVISIONED)
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null

  # Deletion protection
  deletion_protection_enabled = var.deletion_protection_enabled

  # TTL Configuration
  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  # Attributes
  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = global_secondary_index.value.projection_type
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      read_capacity      = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", null) : null
      write_capacity     = var.billing_mode == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", null) : null
    }
  }

  # Local Secondary Indexes
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  # Server-side encryption
  dynamic "server_side_encryption" {
    for_each = local.enable_encryption ? [1] : []
    content {
      enabled     = true
      kms_key_arn = local.kms_key_arn
    }
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }

  # Replica configuration for global tables
  dynamic "replica" {
    for_each = var.replica_regions
    content {
      region_name            = replica.value.region_name
      kms_key_arn            = lookup(replica.value, "kms_key_arn", null)
      propagate_tags         = lookup(replica.value, "propagate_tags", true)
      point_in_time_recovery = lookup(replica.value, "point_in_time_recovery", var.point_in_time_recovery_enabled)
    }
  }

  # Import table from S3 (if configured)
  dynamic "import_table" {
    for_each = var.import_table != null ? [var.import_table] : []
    content {
      input_format = import_table.value.input_format

      s3_bucket_source {
        bucket       = import_table.value.s3_bucket_source.bucket
        bucket_owner = lookup(import_table.value.s3_bucket_source, "bucket_owner", null)
        key_prefix   = lookup(import_table.value.s3_bucket_source, "key_prefix", null)
      }

      dynamic "input_format_options" {
        for_each = lookup(import_table.value, "input_format_options", null) != null ? [import_table.value.input_format_options] : []
        content {
          dynamic "csv" {
            for_each = lookup(input_format_options.value, "csv", null) != null ? [input_format_options.value.csv] : []
            content {
              delimiter   = lookup(csv.value, "delimiter", ",")
              header_list = lookup(csv.value, "header_list", null)
            }
          }
        }
      }
    }
  }

  tags = merge(
    local.common_tags,
    {
      Name = local.table_name
    }
  )

}

# -----------------------------------------------------------------------------
# CloudWatch Contributor Insights
# -----------------------------------------------------------------------------
resource "aws_dynamodb_contributor_insights" "this" {
  count = var.enable_contributor_insights ? 1 : 0

  table_name = aws_dynamodb_table.this.name
}
