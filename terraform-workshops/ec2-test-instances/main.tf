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

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "public_instances" {
  description = "Security Group for instances in Public Subnet"

  ingress {
    description = "Allow SSH from everywhere"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "public" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.public_instances.id]

  tags = {
    Name = "Instance in Public Subnet"
  }
}

output "public_instance_public_ip" {
  value = aws_instance.public.public_ip
}
