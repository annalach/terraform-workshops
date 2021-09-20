terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

resource "random_string" "name" {
  length  = 16
  special = false
}

resource "random_string" "username" {
  length  = 16
  special = false
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
    name     = random_string.name.result
    username = random_string.username.result
    password = random_password.password.result
  })
}
