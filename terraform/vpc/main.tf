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

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "TerraformWorkshopsVPC"
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets_cidr_blocks)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraformWorkshopsPublicSubnet"
  }
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets_cidr_blocks)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnets_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "TerraformWorkshopsPrivateSubnet"
  }
}

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "TerraformWorkshopsInternetGateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  tags = {
    Name = "TerraformWorkshopsPublicRouteTable"
  }
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "sm_vpc_endpoint" {
  vpc_id      = aws_vpc.vpc.id
  description = "Security Group for VPC Endpoint for Secrets Manager"

  ingress {
    description = "Allow HTTPS from EC2 instances from Private and Public Subnet"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = concat(aws_subnet.private_subnets.*.cidr_block, aws_subnet.public_subnets.*.cidr_block)
  }
}

resource "aws_vpc_endpoint" "sm" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.eu-central-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  security_group_ids = [
    aws_security_group.sm_vpc_endpoint.id
  ]

  subnet_ids = aws_subnet.private_subnets.*.id

}
