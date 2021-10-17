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

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_id" "db_secret_suffix" {
  byte_length = 8
}

resource "aws_secretsmanager_secret" "db_secret" {
  name = "db-secret-${random_id.db_secret_suffix.b64_std}"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    name     = "workshopsdb"
    username = "workshopsuser"
    password = random_password.password.result
  })
}
