locals {
  project_name = replace(var.project_name, "_", "-")
}

data "aws_availability_zones" "main" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "${local.project_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  for_each = {
    for k, v in data.aws_availability_zones.main.names : k => v
  }
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, each.key + 1)

  tags = {
    Name = "${local.project_name}-private-subnet-${substr(each.value, -1, 1)}"
  }
}

resource "aws_route_table" "main" {
  for_each = aws_subnet.main

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.project_name}-route-table-main-${each.key}"
  }
}

resource "aws_route_table_association" "main" {
  for_each = aws_subnet.main

  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.main[each.key].id
}

# resource "aws_security_group" "allow_aurora" {
#   name        = "allow_aurora"
#   description = "Allow inbound traffic from the VPC to the Aurora cluster."
#   vpc_id      = aws_vpc.main.id
# 
#   tags = {
#     Name = "${local.project_name}-allow-aurora"
#   }
# }
# 
# module "aurora" {
#   source  = "terraform-aws-modules/rds-aurora/aws//examples/postgresql"
#   version = "9.9.1"
# 
#   name            = "${local.project_name}-aurora"
#   engine          = "aurora-postgresql"
#   engine_version  = "16.3"
#   master_username = "postgres"
#   storage_type    = "aurora-iopt1"
#   instances = {
#     1 = {
#       instance_class          = "db.r5.2xlarge"
#       publicly_accessible     = false
#       db_parameter_group_name = "default.aurora-postgresql6"
#     }
#     2 = {
#       identifier     = "static-member-1"
#       instance_class = "db.r5.2xlarge"
#     }
#     3 = {
#       identifier     = "excluded-member-1"
#       instance_class = "db.r5.large"
#       promotion_tier = 15
#     }
#   }
# 
#   endpoints = {
#     static = {
#       identifier     = "static-custom-endpt"
#       type           = "ANY"
#       static_members = ["static-member-1"]
#       tags           = { Endpoint = "static-members" }
#     }
#     excluded = {
#       identifier       = "excluded-custom-endpt"
#       type             = "READER"
#       excluded_members = ["excluded-member-1"]
#       tags             = { Endpoint = "excluded-members" }
#     }
#   }
# 
#   vpc_id               = module.vpc.vpc_id
#   db_subnet_group_name = module.vpc.database_subnet_group_name
#   security_group_rules = {
#     vpc_ingress = {
#       cidr_blocks = module.vpc.private_subnets_cidr_blocks
#     }
#     egress_example = {
#       type        = "egress"
#       cidr_blocks = ["10.33.0.0/28"]
#       description = "Egress to corporate printer closet"
#     }
#   }
# 
#   apply_immediately   = true
#   skip_final_snapshot = true
# 
#   engine_lifecycle_support = "open-source-rds-extended-support-disabled"
# 
#   create_db_cluster_parameter_group      = true
#   db_cluster_parameter_group_name        = local.name
#   db_cluster_parameter_group_family      = "aurora-postgresql14"
#   db_cluster_parameter_group_description = "${local.name} example cluster parameter group"
#   db_cluster_parameter_group_parameters = [
#     {
#       name         = "log_min_duration_statement"
#       value        = 4000
#       apply_method = "immediate"
#       }, {
#       name         = "rds.force_ssl"
#       value        = 1
#       apply_method = "immediate"
#     }
#   ]
# 
#   create_db_parameter_group      = true
#   db_parameter_group_name        = local.name
#   db_parameter_group_family      = "aurora-postgresql14"
#   db_parameter_group_description = "${local.name} example DB parameter group"
#   db_parameter_group_parameters = [
#     {
#       name         = "log_min_duration_statement"
#       value        = 4000
#       apply_method = "immediate"
#     }
#   ]
# 
#   create_db_cluster_activity_stream     = true
#   db_cluster_activity_stream_kms_key_id = module.kms.key_id
#   db_cluster_activity_stream_mode       = "async"
# 
#   tags = local.tags
# }
