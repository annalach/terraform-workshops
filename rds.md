# 7. Relational Database Service

{% code title="terraform/network/outputs.tf" %}
```bash
@@ -12,3 +12,8 @@ output "private_subnet_ids" {
   description = "Private Subnets' Ids"
   value       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
 }
+
+output "private_subnets_cidr_blocks" {
+  description = "Private Subnets' CIDR blocks"
+  value       = [aws_subnet.private_subnet_a.cidr_block, aws_subnet.private_subnet_b.cidr_block]
+}

```
{% endcode %}

{% code title="terraform/database/main.tf" %}
```bash
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

```
{% endcode %}

{% code title="terraform/database/outputs.tf" %}
```bash
output "endpoint" {
  value = aws_db_instance.rds.endpoint
}
```
{% endcode %}

Apply.

Login via SSH into the EC2 instance in the private subnet and try to execute a simple select statement using postgresql-client:

```bash
ubuntu@ip-10-0-3-190:~$ aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-Q10poK4uyxg=-M7gcK6 --region eu-central-1

{
    "ARN": "arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-Q10poK4uyxg=-M7gcK6",
    "Name": "db-secret-Q10poK4uyxg=",
    "VersionId": "4F1F9B12-8B17-4C0C-8137-1B4CB58B57C2",
    "SecretString": "{\"name\":\"workshopsdb\",\"password\":\"Bn_JsL0Xcpqr5_fM\",\"username\":\"workshopsuser\"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": 1634507285.353
}

ubuntu@ip-10-0-3-190:~$ psql postgresql://workshopsuser:Bn_JsL0Xcpqr5_fM@terraform-20211017224426876800000003.csiqwc1tjv12.eu-central-1.rds.amazonaws.com:5432/workshopsdb -c 'select now()'
              now              
-------------------------------
 2021-10-17 22:54:00.496107+00
(1 row)
```

