# 3. Virtual Private Cloud

## VPC configuration

```text
$ cd ..
$ mkdir vpc
$ cd vpc
$ touch main.tf
```

```bash
$ terraform init
```

{% code title="terraform-workshops/vpc/mainf.tf" %}
```bash
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
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraformWorkshopsVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "TerraformWorkshopsPublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

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

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
```
{% endcode %}

```text
$ terraform apply
```

```text
$ touch outputs.tf
```

{% code title="terraform-workshops/vpc/outputs.tf" %}
```bash
output "vpc_id" {
  description = "The VPC Id"
  value       = aws_vpc.vpc.id
}

output "public_subnet_id" {
  description = "The Public Subnet Id"
  value       = aws_subnet.public_subnet.id
}

output "public_subnet_cidr_block" {
  description = "The Public Subnet CIDR"
  value       = aws_subnet.public_subnet.cidr_block
}

output "private_subnet_id" {
  description = "The Private Subnet Id"
  value       = aws_subnet.private_subnet.id
}
```
{% endcode %}

## The terraform\_remote\_state Data Source

