# =============================================================================
# CloudWatch Alarms for Monitoring
# =============================================================================

# -----------------------------------------------------------------------------
# Read Throttle Events Alarm
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_throttle_events" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.table_name}-read-throttle-events"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_read_throttle_events.evaluation_periods
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = var.alarm_read_throttle_events.period
  statistic           = "Sum"
  threshold           = var.alarm_read_throttle_events.threshold
  alarm_description   = "Triggered when read throttle events exceed threshold for ${local.table_name}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.this.name
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Write Throttle Events Alarm
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_throttle_events" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.table_name}-write-throttle-events"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_write_throttle_events.evaluation_periods
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = var.alarm_write_throttle_events.period
  statistic           = "Sum"
  threshold           = var.alarm_write_throttle_events.threshold
  alarm_description   = "Triggered when write throttle events exceed threshold for ${local.table_name}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.this.name
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# User Errors Alarm
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "user_errors" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${local.table_name}-user-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_user_errors.evaluation_periods
  metric_name         = "UserErrors"
  namespace           = "AWS/DynamoDB"
  period              = var.alarm_user_errors.period
  statistic           = "Sum"
  threshold           = var.alarm_user_errors.threshold
  alarm_description   = "Triggered when user errors exceed threshold for ${local.table_name}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    TableName = aws_dynamodb_table.this.name
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions

  tags = local.common_tags
}
