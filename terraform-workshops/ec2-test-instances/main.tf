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

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    "path" = "../vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    "path" = "../iam/terraform.tfstate"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["myEC2TestInstance"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["self"]
}

resource "aws_security_group" "public_instances" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
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

resource "aws_security_group" "private_instances" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Security Group for instances in Private Subnet"

  ingress {
    description = "Allow SSH from EC2 instance from Public Subnet"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [data.terraform_remote_state.vpc.outputs.public_subnet_cidr_block]
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
  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
  iam_instance_profile   = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name

  tags = {
    Name = "TerraformWorkshopsEC2InPublicSubnet"
  }
}

resource "aws_instance" "private" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_ec2_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.private_instances.id]
  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_id
  iam_instance_profile   = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name

  tags = {
    Name = "TerraformWorkshopsEC2InPrivateSubnet"
  }
}

output "public_instance_public_ip" {
  value = aws_instance.public.public_ip
}

output "private_instance_private_ip" {
  value = aws_instance.private.private_ip
}
