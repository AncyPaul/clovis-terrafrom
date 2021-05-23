provider "aws" {
  region = "us-east-1"
}
module "rds" {
    source = "/root/clovis/rds"

    db_subnet_group_name = "demo-db-subnet-group"
    db_subnet_ids = ["subnet-ef0cf6a2", "subnet-fb23099c"]

    db_parameter_group_name = "demo-db-parameter-group"
    db_parameter_group_family = "mysql5.7"

    db_option_group_name = "demo-db-option-group"
    db_option_group_engine = "mysql"
    db_option_group_engine_version = "5.7"

    db_instance_count = "1"
    db_identifier = "demodbnew"
    db_engine = "mysql"
    db_engine_version = "5.7.19"
    db_instance_class = "db.t2.micro"
    db_allocated_storage = "5"
    db_storage_type = "gp2"
    db_name = "demodb"
    db_username = "admin"
    db_password = "admin123"
    db_port = "3306"
    #db_domain = ""
    db_vpc_security_group_ids = ["sg-080f3c783590bd585"]
    #availability_zone = ""
    maintenance_window = "Mon:00:00-Mon:03:00"
    #snapshot_identifier = ""
    #performance_insights_retention_period = ""
    #backup_retention_period = ""
    final_identifier = "mydemodb"
    final_snapshot_identifier_prefix = "snap"
    backup_window = "03:00-06:00"
    #monitoring_interval = "0"

    tags = {
        Owner       = "user"
        Environment = "dev"
    }
}
