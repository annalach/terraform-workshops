terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.62.0"
    }
  }

  required_version = ">= 1.0.8"
}

provider "aws" {
  region = "eu-central-1"
}

data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    "path" = "../network/terraform.tfstate"
  }
}

data "terraform_remote_state" "secrets" {
  backend = "local"

  config = {
    "path" = "../secrets/terraform.tfstate"
  }
}

data "aws_secretsmanager_secret_version" "db_secret" {
  secret_id = data.terraform_remote_state.secrets.outputs.db_secert_arn
}

locals {
  secret = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string)
}

resource "aws_db_subnet_group" "rds" {
  subnet_ids = data.terraform_remote_state.network.outputs.private_subnet_ids

  tags = {
    Name = "TerraformWorkshopsDBSubnetGroup"
  }
}

resource "aws_security_group" "rds" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.network.outputs.private_subnets_cidr_blocks
  }
}

resource "aws_db_instance" "rds" {
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12"
  name                   = local.secret.name
  username               = local.secret.username
  password               = local.secret.password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true

  tags = {
    Name = "TerraformWorkshopsRDS"
  }
}
