# =============================================================================
# TFLint Configuration
# =============================================================================

config {
  # Enable all rules by default
  call_module_type = "all"
  force  = false
}

# AWS Plugin Configuration
plugin "aws" {
    enabled = true
    version = "0.45.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Terraform Plugin Configuration
plugin "terraform" {
  enabled = true
  version = "0.14.1"
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"

  preset = "recommended"
}

# =============================================================================
# AWS Specific Rules
# =============================================================================

# Naming Conventions
rule "aws_resource_missing_tags" {
  enabled = true
  tags = [
    "Environment",
    "ManagedBy",
  ]
}

# DynamoDB Specific Rules
rule "aws_dynamodb_table_invalid_name" {
  enabled = true
}

# KMS Rules
rule "aws_kms_key_invalid_key_usage" {
  enabled = true
}

# =============================================================================
# Terraform Best Practices
# =============================================================================

# Enforce module versioning
rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

# Naming conventions
rule "terraform_naming_convention" {
  enabled = true

  variable {
    format = "snake_case"
  }

  locals {
    format = "snake_case"
  }

  output {
    format = "snake_case"
  }

  resource {
    format = "snake_case"
  }

  module {
    format = "snake_case"
  }

  data {
    format = "snake_case"
  }
}

# Documentation
rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

# Module best practices
rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_module_version" {
  enabled = true
}

# Deprecated syntax
rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_deprecated_interpolation" {
  enabled = true
}

# Type constraints
rule "terraform_typed_variables" {
  enabled = true
}

# Unused declarations
rule "terraform_unused_declarations" {
  enabled = true
}

# Workspace usage
rule "terraform_workspace_remote" {
  enabled = true
}

# =============================================================================
# Custom Rules (Optional)
# =============================================================================

# Ensure all resources have proper descriptions
rule "terraform_comment_syntax" {
  enabled = true
}

# Standard module structure
rule "terraform_standard_module_structure" {
  enabled = false
}
