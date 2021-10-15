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

locals {
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
}

resource "aws_security_group" "public" {
  vpc_id = local.vpc_id

  ingress {
    description = "Allow SSH from everywhere"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic on all ports"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  vpc_id = local.vpc_id

  ingress {
    description     = "Allow SSH from EC2 in public subnet"
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.public.id]
  }

  egress {
    description = "Allow outbound traffic on all ports"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my_ec2_key_pair" {
  key_name   = "my-ec2-key-pair"
  public_key = file("~/myEC2KeyPair.pub")
}

resource "aws_instance" "public" {
  ami                         = "ami-091f21ecba031b39a"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my_ec2_key_pair.key_name
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true
}

resource "aws_instance" "private" {
  ami                    = "ami-091f21ecba031b39a"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_ec2_key_pair.key_name
  subnet_id              = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.private.id]
}
