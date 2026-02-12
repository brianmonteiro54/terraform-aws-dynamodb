# =============================================================================
# Variables - DynamoDB Module
# =============================================================================

# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]+$", var.table_name))
    error_message = "Table name must contain only alphanumeric characters, hyphens, underscores, and periods."
  }

  validation {
    condition     = length(var.table_name) >= 3 && length(var.table_name) <= 255
    error_message = "Table name must be between 3 and 255 characters."
  }
}

variable "hash_key" {
  description = "Attribute to use as the hash (partition) key"
  type        = string
}

variable "attributes" {
  description = "List of attribute definitions for the table and indexes"
  type = list(object({
    name = string
    type = string
  }))

  validation {
    condition = alltrue([
      for attr in var.attributes : contains(["S", "N", "B"], attr.type)
    ])
    error_message = "Attribute types must be one of: S (string), N (number), or B (binary)."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

  validation {
    condition     = can(regex("^(dev|development|staging|stage|prod|production|qa|test)$", var.environment))
    error_message = "Environment must be one of: dev, development, staging, stage, prod, production, qa, test."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables - Table Configuration
# -----------------------------------------------------------------------------
variable "table_name_prefix" {
  description = "Prefix to add to table name (useful for multi-environment deployments)"
  type        = string
  default     = ""
}

variable "range_key" {
  description = "Attribute to use as the range (sort) key"
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "read_capacity" {
  description = "Number of read units for this table (only for PROVISIONED billing_mode)"
  type        = number
  default     = 5

  validation {
    condition     = var.read_capacity >= 1
    error_message = "Read capacity must be at least 1."
  }
}

variable "write_capacity" {
  description = "Number of write units for this table (only for PROVISIONED billing_mode)"
  type        = number
  default     = 5

  validation {
    condition     = var.write_capacity >= 1
    error_message = "Write capacity must be at least 1."
  }
}

variable "table_class" {
  description = "Storage class of the table (STANDARD or STANDARD_INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.table_class)
    error_message = "Table class must be either STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

# -----------------------------------------------------------------------------
# Security Variables
# -----------------------------------------------------------------------------
variable "enable_encryption" {
  description = "Enable server-side encryption"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to use for encryption. If not provided, a new key will be created if encryption is enabled"
  type        = string
  default     = null
}

variable "kms_deletion_window_in_days" {
  description = "Duration in days after which the KMS key is deleted after destruction of the resource"
  type        = number
  default     = 30

  validation {
    condition     = var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    error_message = "KMS deletion window must be between 7 and 30 days."
  }
}

variable "enable_multi_region" {
  description = "Enable multi-region KMS key"
  type        = bool
  default     = false
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery (PITR) for the table"
  type        = bool
  default     = true
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection for the table"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# TTL Configuration
# -----------------------------------------------------------------------------
variable "ttl_enabled" {
  description = "Enable Time to Live for items in the table"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the table attribute to store the TTL timestamp"
  type        = string
  default     = "ttl"
}

# -----------------------------------------------------------------------------
# Streams Configuration
# -----------------------------------------------------------------------------
variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Type of information written to the stream (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"

  validation {
    condition     = contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be one of: KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES."
  }
}

# -----------------------------------------------------------------------------
# Global Secondary Indexes
# -----------------------------------------------------------------------------
variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []

  validation {
    condition = alltrue([
      for gsi in var.global_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], gsi.projection_type)
    ])
    error_message = "GSI projection_type must be one of: ALL, KEYS_ONLY, or INCLUDE."
  }
}

# -----------------------------------------------------------------------------
# Local Secondary Indexes
# -----------------------------------------------------------------------------
variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for lsi in var.local_secondary_indexes : contains(["ALL", "KEYS_ONLY", "INCLUDE"], lsi.projection_type)
    ])
    error_message = "LSI projection_type must be one of: ALL, KEYS_ONLY, or INCLUDE."
  }
}

# -----------------------------------------------------------------------------
# Auto Scaling Configuration
# -----------------------------------------------------------------------------
variable "autoscaling_enabled" {
  description = "Enable auto scaling for provisioned capacity"
  type        = bool
  default     = false
}

variable "autoscaling_read" {
  description = "Auto scaling configuration for read capacity"
  type = object({
    max_capacity       = number
    min_capacity       = number
    target_value       = number
    scale_in_cooldown  = optional(number, 60)
    scale_out_cooldown = optional(number, 60)
  })
  default = {
    max_capacity       = 100
    min_capacity       = 5
    target_value       = 70
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

variable "autoscaling_write" {
  description = "Auto scaling configuration for write capacity"
  type = object({
    max_capacity       = number
    min_capacity       = number
    target_value       = number
    scale_in_cooldown  = optional(number, 60)
    scale_out_cooldown = optional(number, 60)
  })
  default = {
    max_capacity       = 100
    min_capacity       = 5
    target_value       = 70
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

# -----------------------------------------------------------------------------
# Global Tables (Multi-Region Replication)
# -----------------------------------------------------------------------------
variable "replica_regions" {
  description = "List of replica regions for global tables"
  type = list(object({
    region_name            = string
    kms_key_arn            = optional(string)
    propagate_tags         = optional(bool, true)
    point_in_time_recovery = optional(bool)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Import Table Configuration
# -----------------------------------------------------------------------------
variable "import_table" {
  description = "Configuration for importing data from S3"
  type = object({
    input_format = string
    s3_bucket_source = object({
      bucket       = string
      bucket_owner = optional(string)
      key_prefix   = optional(string)
    })
    input_format_options = optional(object({
      csv = optional(object({
        delimiter   = optional(string, ",")
        header_list = optional(list(string))
      }))
    }))
  })
  default = null
}

# -----------------------------------------------------------------------------
# CloudWatch Monitoring
# -----------------------------------------------------------------------------
variable "enable_contributor_insights" {
  description = "Enable CloudWatch Contributor Insights for the table"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for monitoring"
  type        = bool
  default     = true
}

variable "alarm_read_throttle_events" {
  description = "Configuration for read throttle events alarm"
  type = object({
    threshold          = number
    evaluation_periods = number
    period             = number
  })
  default = {
    threshold          = 10
    evaluation_periods = 2
    period             = 300
  }
}

variable "alarm_write_throttle_events" {
  description = "Configuration for write throttle events alarm"
  type = object({
    threshold          = number
    evaluation_periods = number
    period             = number
  })
  default = {
    threshold          = 10
    evaluation_periods = 2
    period             = 300
  }
}

variable "alarm_user_errors" {
  description = "Configuration for user errors alarm"
  type = object({
    threshold          = number
    evaluation_periods = number
    period             = number
  })
  default = {
    threshold          = 10
    evaluation_periods = 2
    period             = 300
  }
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm transitions to ALARM state"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm transitions to OK state"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Backup Configuration
# -----------------------------------------------------------------------------
variable "enable_backup_plan" {
  description = "Enable AWS Backup plan for the table"
  type        = bool
  default     = false
}

variable "backup_vault_name" {
  description = "Name of the AWS Backup vault"
  type        = string
  default     = "Default"
}

variable "backup_schedule" {
  description = "Cron expression for backup schedule"
  type        = string
  default     = "cron(0 2 * * ? *)" # Daily at 2 AM UTC
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_retention_days >= 1
    error_message = "Backup retention must be at least 1 day."
  }
}

variable "backup_iam_role_arn" {
  description = "ARN of the IAM role for AWS Backup service"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# IAM Policy Configuration
# -----------------------------------------------------------------------------
variable "create_iam_policy" {
  description = "Create an IAM policy for accessing the DynamoDB table"
  type        = bool
  default     = false
}

variable "iam_policy_allow_write" {
  description = "Allow write operations in the IAM policy"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "cost_center" {
  description = "Cost center for billing purposes"
  type        = string
  default     = "engineering"
}
