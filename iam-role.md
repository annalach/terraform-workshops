# 5. IAM Role

{% code title="terraform/iam/main.tf" %}
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

data "terraform_remote_state" "secrets" {
  backend = "local"

  config = {
    "path" = "../secrets/terraform.tfstate"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "terraform-workshops-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "terraform-workshops-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy" "ec2_policy" {
  name = "terraform-workshops-ec2-policy"
  role = aws_iam_role.ec2_role.id

  policy = <<-EOT
           {
               "Version" : "2012-10-17",
               "Statement" : {
                 "Effect" : "Allow",
                 "Action" : "secretsmanager:GetSecretValue",
                 "Resource" : "${data.terraform_remote_state.secrets.outputs.db_secert_arn}"
               }
           }
           EOT
}

```
{% endcode %}

{% code title="terraform/iam/outputs.tf" %}
```bash
output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}
```
{% endcode %}

Apply.

Update `webserver-cluster` config:

{% code title="terraform/webserver-cluster.main.tf" %}
```bash
@@ -21,8 +21,17 @@ data "terraform_remote_state" "network" {
   }
 }
 
+data "terraform_remote_state" "iam" {
+  backend = "local"
+
+  config = {
+    "path" = "../iam/terraform.tfstate"
+  }
+}
+
 locals {
-  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
+  vpc_id               = data.terraform_remote_state.network.outputs.vpc_id
+  iam_instance_profile = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name
 }
 
 resource "aws_security_group" "public" {
@@ -77,6 +86,7 @@ resource "aws_instance" "public" {
   subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
   vpc_security_group_ids      = [aws_security_group.public.id]
   associate_public_ip_address = true
+  iam_instance_profile        = local.iam_instance_profile
 }
 
 resource "aws_instance" "private" {
@@ -85,4 +95,5 @@ resource "aws_instance" "private" {
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   subnet_id              = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
   vpc_security_group_ids = [aws_security_group.private.id]
+  iam_instance_profile   = local.iam_instance_profile
 }
 
```
{% endcode %}

Connect via SSH with the EC2 instance, install the AWS CLI (and postgresql-client, we will use it later), and try to read the secret's value:

```bash
ubuntu@ip-10-0-1-81:~$ sudo apt-get update

ubuntu@ip-10-0-1-81:~$ sudo apt-get install awscli postgresql-client

ubuntu@ip-10-0-1-81:~$ aws --version

ubuntu@ip-10-0-1-81:~$ aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-G7kbe9TbeCI=-sMOQ9J --region eu-central-1
```

The EC2 instance that is running in the private subnet doesn't have a route to the Internet, which means we are not able to install the AWS CLI using the package manager. To work around the issue, go to the AWS Console and create Amazon Machine Image from the EC2 instance which is running in the public subnet. Once AMI is available, update `ami` value in the `main.tf `file and rebuild module.

```
@@ -90,7 +90,7 @@ resource "aws_instance" "public" {
 }
 
 resource "aws_instance" "private" {
-  ami                    = "ami-091f21ecba031b39a"
+  ami                    = "ami-0e56174c299a6ff07" # your AMI ID
   instance_type          = "t2.micro"
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   subnet_id              = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
```

Test whether you can read the secret's value from the EC2 instance running in the private subnet.
