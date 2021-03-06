locals {
  is_individual_account = var.account_type == "individual"
  is_master_account     = var.account_type == "master"
  is_member_account     = var.account_type == "member"

  is_cloudtrail_enabled = local.is_individual_account || local.is_master_account
}

# --------------------------------------------------------------------------------------------------
# IAM Baseline
# --------------------------------------------------------------------------------------------------

module "iam_baseline" {
  source = "github.com/nozaq/terraform-aws-secure-baseline//modules/iam-baseline?ref=0.17.0"

  aws_account_id                  = var.aws_account_id
  master_iam_role_name            = var.master_iam_role_name
  master_iam_role_policy_name     = var.master_iam_role_policy_name
  manager_iam_role_name           = var.manager_iam_role_name
  manager_iam_role_policy_name    = var.manager_iam_role_policy_name
  support_iam_role_name           = var.support_iam_role_name
  support_iam_role_policy_name    = var.support_iam_role_policy_name
  support_iam_role_principal_arns = var.support_iam_role_principal_arns
  minimum_password_length         = var.minimum_password_length
  password_reuse_prevention       = var.password_reuse_prevention
  require_lowercase_characters    = var.require_lowercase_characters
  require_numbers                 = var.require_numbers
  require_uppercase_characters    = var.require_uppercase_characters
  require_symbols                 = var.require_symbols
  allow_users_to_change_password  = var.allow_users_to_change_password
  max_password_age                = var.max_password_age

  tags = var.tags
}

# --------------------------------------------------------------------------------------------------
# CloudTrail Baseline
# --------------------------------------------------------------------------------------------------

module "cloudtrail_baseline" {
  source = "github.com/nozaq/terraform-aws-secure-baseline//modules/cloudtrail-baseline?ref=0.17.0"

  enabled                           = local.is_cloudtrail_enabled
  aws_account_id                    = var.aws_account_id
  cloudtrail_name                   = var.cloudtrail_name
  cloudtrail_sns_topic_name         = var.cloudtrail_sns_topic_name
  cloudwatch_logs_group_name        = var.cloudtrail_cloudwatch_logs_group_name
  cloudwatch_logs_retention_in_days = var.cloudwatch_logs_retention_in_days
  iam_role_name                     = var.cloudtrail_iam_role_name
  iam_role_policy_name              = var.cloudtrail_iam_role_policy_name
  key_deletion_window_in_days       = var.cloudtrail_key_deletion_window_in_days
  region                            = var.region
  s3_bucket_name                    = local.audit_log_bucket_id
  s3_key_prefix                     = var.cloudtrail_s3_key_prefix
  is_organization_trail             = local.is_master_account
  tags                              = var.tags
}

# --------------------------------------------------------------------------------------------------
# CloudWatch Alarms Baseline
# --------------------------------------------------------------------------------------------------

module "alarm_baseline" {
  source = "github.com/nozaq/terraform-aws-secure-baseline//modules/alarm-baseline?ref=0.17.0"

  enabled                   = local.is_cloudtrail_enabled
  alarm_namespace           = var.alarm_namespace
  cloudtrail_log_group_name = local.is_cloudtrail_enabled ? module.cloudtrail_baseline.log_group.name : ""
  sns_topic_name            = var.alarm_sns_topic_name

  tags = var.tags
}

# --------------------------------------------------------------------------------------------------
# SecurityHub Baseline
# --------------------------------------------------------------------------------------------------

module "securityhub_baseline" {
  source = "github.com/nozaq/terraform-aws-secure-baseline//modules/securityhub-baseline?ref=0.17.0"
}
