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

resource "aws_security_group" "webserver" {
  description = "Security group for webserver"

  ingress {
    description = "Allow SSH from everywhere"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound on port 5000"
    protocol    = "tcp"
    from_port   = 5000
    to_port     = 5000
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outboud traffic on all ports"
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

resource "aws_instance" "webserver" {
  ami                    = "ami-091f21ecba031b39a"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.webserver.id]

  tags = {
    Name = "TerraformWorkshops"
  }
}
