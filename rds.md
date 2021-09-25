# 7. Relational Database Service

{% code title="terraform-workshops/vpc/variables.tf" %}
```bash
variable "vpc_cidr_block" {
  description = "The VPC cidr block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr_blocks" {
  description = "Public subnets cidr blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
}

variable "private_subnets_cidr_blocks" {
  description = "Private subnets cidr blocks"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]
}
```
{% endcode %}

{% code title="terraform-workshops/vpc/outputs.tf" %}
```bash
@@ -3,17 +3,22 @@ output "vpc_id" {
   value       = aws_vpc.vpc.id
 }
 
-output "public_subnet_id" {
-  description = "The Public Subnet Id"
-  value       = aws_subnet.public_subnet.id
+output "public_subnets_ids" {
+  value       = aws_subnet.public_subnets.*.id
+  description = "Public Subnets' Ids"
 }
 
-output "public_subnet_cidr_block" {
-  description = "The Public Subnet CIDR"
-  value       = aws_subnet.public_subnet.cidr_block
+output "private_subnet_ids" {
+  value       = aws_subnet.private_subnets.*.id
+  description = "Private Subnets' Ids"
 }
 
-output "private_subnet_id" {
-  description = "The Private Subnet Id"
-  value       = aws_subnet.private_subnet.id
+output "public_subnets_cidr_blocks" {
+  value       = aws_subnet.public_subnets.*.cidr_block
+  description = "Public Subnets' CIDR blocks"
+}
+
+output "private_subnets_cidr_blocks" {
+  value       = aws_subnet.private_subnets.*.cidr_block
+  description = "Private Subnets' CIDR blocks"
 }
```
{% endcode %}

```bash
@@ -19,7 +19,7 @@ data "aws_availability_zones" "available" {
 }
 
 resource "aws_vpc" "vpc" {
-  cidr_block           = "10.0.0.0/16"
+  cidr_block           = var.vpc_cidr_block
   enable_dns_support   = true
   enable_dns_hostnames = true
 
@@ -28,10 +28,12 @@ resource "aws_vpc" "vpc" {
   }
 }
 
-resource "aws_subnet" "public_subnet" {
+resource "aws_subnet" "public_subnets" {
+  count = length(var.public_subnets_cidr_blocks)
+
   vpc_id                  = aws_vpc.vpc.id
-  cidr_block              = "10.0.1.0/24"
-  availability_zone       = data.aws_availability_zones.available.names[0]
+  cidr_block              = var.public_subnets_cidr_blocks[count.index]
+  availability_zone       = data.aws_availability_zones.available.names[count.index]
   map_public_ip_on_launch = true
 
   tags = {
@@ -39,10 +41,12 @@ resource "aws_subnet" "public_subnet" {
   }
 }
 
-resource "aws_subnet" "private_subnet" {
+resource "aws_subnet" "private_subnets" {
+  count = length(var.private_subnets_cidr_blocks)
+
   vpc_id            = aws_vpc.vpc.id
-  cidr_block        = "10.0.2.0/24"
-  availability_zone = data.aws_availability_zones.available.names[0]
+  cidr_block        = var.private_subnets_cidr_blocks[count.index]
+  availability_zone = data.aws_availability_zones.available.names[count.index]
 
   tags = {
     Name = "TerraformWorkshopsPrivateSubnet"
@@ -70,8 +74,10 @@ resource "aws_route_table" "public_route_table" {
   }
 }
 
-resource "aws_route_table_association" "a" {
-  subnet_id      = aws_subnet.public_subnet.id
+resource "aws_route_table_association" "public" {
+  count = length(aws_subnet.public_subnets)
+
+  subnet_id      = aws_subnet.public_subnets[count.index].id
   route_table_id = aws_route_table.public_route_table.id
 }
 
@@ -84,7 +90,7 @@ resource "aws_security_group" "sm_vpc_endpoint" {
     protocol    = "tcp"
     from_port   = 443
     to_port     = 443
-    cidr_blocks = [aws_subnet.private_subnet.cidr_block, aws_subnet.public_subnet.cidr_block]
+    cidr_blocks = concat(aws_subnet.private_subnets.*.cidr_block, aws_subnet.public_subnets.*.cidr_block)
   }
 }
 
@@ -98,7 +104,6 @@ resource "aws_vpc_endpoint" "sm" {
     aws_security_group.sm_vpc_endpoint.id
   ]
 
-  subnet_ids = [
-    aws_subnet.private_subnet.id
-  ]
+  subnet_ids = aws_subnet.private_subnets.*.id
+
 }
```

{% code title="terraform-workshops/database/main.tf" %}
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

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    "path" = "../vpc/terraform.tfstate"
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

resource "aws_db_subnet_group" "rds" {
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  tags = {
    Name = "TerraformWorkshopsDBSubnetGroup"
  }
}

resource "aws_security_group" "rds" {
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  description = "Security Group for RDS in Private Subnet"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets_cidr_blocks
  }
}

resource "aws_db_instance" "rds" {
  instance_class         = "db.t2.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "12"
  name                   = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string).name
  username               = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string).username
  password               = jsondecode(data.aws_secretsmanager_secret_version.db_secret.secret_string).password
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true

  tags = {
    Name = "TerraformWorkshopsRDS"
  }
}
```
{% endcode %}

{% code title="terraform-workshops/ec2-test-instances/main.tf" %}
```bash
@@ -76,7 +76,7 @@ resource "aws_security_group" "private_instances" {
     protocol    = "tcp"
     from_port   = 22
     to_port     = 22
-    cidr_blocks = [data.terraform_remote_state.vpc.outputs.public_subnet_cidr_block]
+    cidr_blocks = data.terraform_remote_state.vpc.outputs.public_subnets_cidr_blocks
   }

   egress {
@@ -98,7 +98,7 @@ resource "aws_instance" "public" {
   instance_type          = "t2.micro"
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   vpc_security_group_ids = [aws_security_group.public_instances.id]
-  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
+  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnets_ids[0]
   iam_instance_profile   = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name

   tags = {
@@ -111,7 +111,7 @@ resource "aws_instance" "private" {
   instance_type          = "t2.micro"
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   vpc_security_group_ids = [aws_security_group.private_instances.id]
-  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_id
+  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
   iam_instance_profile   = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name

   tags = {
```
{% endcode %}

```bash
$ sudo apt-get install postgresql-client
$ psql --version
```



