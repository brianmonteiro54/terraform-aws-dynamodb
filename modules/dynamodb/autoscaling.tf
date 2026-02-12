# =============================================================================
# Auto Scaling for Provisioned Capacity
# =============================================================================

# -----------------------------------------------------------------------------
# Read Capacity Auto Scaling
# -----------------------------------------------------------------------------
resource "aws_appautoscaling_target" "dynamodb_table_read" {
  count = local.create_autoscaling_read ? 1 : 0

  max_capacity       = var.autoscaling_read.max_capacity
  min_capacity       = var.autoscaling_read.min_capacity
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  count = local.create_autoscaling_read ? 1 : 0

  name               = "${local.table_name}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value       = var.autoscaling_read.target_value
    scale_in_cooldown  = var.autoscaling_read.scale_in_cooldown
    scale_out_cooldown = var.autoscaling_read.scale_out_cooldown
  }
}

# -----------------------------------------------------------------------------
# Write Capacity Auto Scaling
# -----------------------------------------------------------------------------
resource "aws_appautoscaling_target" "dynamodb_table_write" {
  count = local.create_autoscaling_write ? 1 : 0

  max_capacity       = var.autoscaling_write.max_capacity
  min_capacity       = var.autoscaling_write.min_capacity
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  count = local.create_autoscaling_write ? 1 : 0

  name               = "${local.table_name}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value       = var.autoscaling_write.target_value
    scale_in_cooldown  = var.autoscaling_write.scale_in_cooldown
    scale_out_cooldown = var.autoscaling_write.scale_out_cooldown
  }
}
