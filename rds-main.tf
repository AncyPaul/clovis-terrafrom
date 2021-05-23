# locals {
#   master_password      = var.create_db_instance && var.create_random_password ? random_password.master_password[0].result : var.password
#   db_subnet_group_name = var.replicate_source_db != null ? null : coalesce(var.db_subnet_group_name, module.db_subnet_group.db_subnet_group_id)

#   parameter_group_name_id = var.create_db_parameter_group ? module.db_parameter_group.db_parameter_group_id : var.parameter_group_name

#   create_db_option_group = var.create_db_option_group && var.engine != "postgres"
#   option_group           = local.create_db_option_group ? module.db_option_group.db_option_group_id : var.option_group_name
# }

resource "random_password" "master_password" {
  count = var.create_db_instance && var.create_random_password ? 1 : 0

  length  = var.random_password_length
  special = false
}

resource "aws_db_subnet_group" "db_subnet_group" {
    count = var.create_db_subnet_group ? 1 : 0
    name = var.db_subnet_group_name
    subnet_ids = var.db_subnet_ids
    tags = merge(var.tags, {"Name" = var.db_subnet_group_name })
    #### need to change the tag####
}

resource "aws_db_parameter_group" "db_parameter_group" {
    count = var.create_db_parameter_group ? 1 : 0
    name = var.db_parameter_group_name
    family = var.db_parameter_group_family
    # dynamic "parameter" {
    #     for_each = var.parameters
    #     content {
    #         name         = parameter.value.name
    #         value        = parameter.value.value
    #         apply_method = lookup(parameter.value, "apply_method", null)
    #     }
    # }
    # lifecycle {
    #     create_before_destroy = true
    # }
    tags = merge(var.tags, {"Name" = var.db_parameter_group_name })
}

resource "aws_db_option_group" "db_option_group" {
    count = var.create_db_option_group ? 1 : 0
    name = var.db_option_group_name
    engine_name = var.db_option_group_engine
    major_engine_version = var.db_option_group_engine_version
    # dynamic "option" {
    #     for_each = var.options
    #     content {
    #         option_name                    = option.value.option_name
    #         port                           = lookup(option.value, "port", null)
    #         version                        = lookup(option.value, "version", null)
    #         db_security_group_memberships  = lookup(option.value, "db_security_group_memberships", null)
    #         vpc_security_group_memberships = lookup(option.value, "vpc_security_group_memberships", null)
    #         dynamic "option_settings" {
    #             for_each = lookup(option.value, "option_settings", [])
    #             content {
    #                 name  = lookup(option_settings.value, "name", null)
    #                 value = lookup(option_settings.value, "value", null)
    #             }
    #         }
    #     }
    # }
    # timeouts {
    #     delete = lookup(var.timeouts, "delete", null)
    # }
    # lifecycle {
    #     create_before_destroy = true
    # }
    tags = merge(var.tags, {"Name" = var.db_option_group_name })
}

resource "random_id" "snapshot_identifier" {
  count = var.create_random_id && !var.skip_final_snapshot ? 1 : 0
  keepers = {
    id = var.db_identifier
  }

  byte_length = 4
}

resource "aws_db_instance" "db_instance" {
    count                                 = var.create_db_instance ? var.db_instance_count : 0
    identifier                            = var.db_identifier
    engine                                = var.db_engine
    engine_version                        = var.db_engine_version
    instance_class                        = var.db_instance_class
    allocated_storage                     = var.db_allocated_storage
    storage_type                          = var.db_storage_type
    storage_encrypted                     = var.db_storage_encrypted
    #kms_key_id                            = var.db_kms_key_id
    #license_model                         = var.db_license_model

    name                                  = var.db_name
    username                              = var.db_username
    password                              = var.db_password
    port                                  = var.db_port
    domain                                = var.db_domain
    #domain_iam_role_name                  = var.db_domain_iam_role_name
    iam_database_authentication_enabled   = var.iam_database_authentication_enabled

    vpc_security_group_ids                = var.db_vpc_security_group_ids
    parameter_group_name                  = aws_db_parameter_group.db_parameter_group[count.index].id
    option_group_name                     = aws_db_option_group.db_option_group[count.index].id
    db_subnet_group_name                  = aws_db_subnet_group.db_subnet_group[count.index].id

    availability_zone                     = var.availability_zone
    multi_az                              = var.multi_az
    iops                                  = var.iops
    publicly_accessible                   = var.publicly_accessible
    #ca_cert_identifier                    = var.ca_cert_identifier

    allow_major_version_upgrade           = var.allow_major_version_upgrade
    auto_minor_version_upgrade            = var.auto_minor_version_upgrade
    apply_immediately                     = var.apply_immediately
    maintenance_window                    = var.maintenance_window

    snapshot_identifier                   = var.snapshot_identifier
    copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
    skip_final_snapshot                   = var.skip_final_snapshot
#    final_snapshot_identifier             = var.skip_final_snapshot ? null : coalesce(var.final_identifier, "${var.final_snapshot_identifier_prefix}-${var.db_identifier}-${random_id.snapshot_identifier[0].hex}")
    final_snapshot_identifier = "ancy"

    performance_insights_enabled          = var.performance_insights_enabled
    performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
    #performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null

    #replicate_source_db                   = var.replicate_source_db
    backup_retention_period               = var.backup_retention_period
    backup_window                         = var.backup_window
    max_allocated_storage                 = var.max_allocated_storage
    #monitoring_interval                   = var.monitoring_interval
    #monitoring_role_arn                   = var.monitoring_interval > 0 ? local.monitoring_role_arn : null

    #character_set_name                    = var.character_set_name
    #enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports

    deletion_protection                   = var.deletion_protection
    delete_automated_backups              = var.delete_automated_backups
    tags = merge(var.tags, {"Name" = var.db_identifier })
}
