# 5. IAM Role

```text
$ mkdir iam
$ cd iam
$ touch main.tf
```

{% code title="terraform-workshops/iam/main.tf" %}
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

  policy = <<EOT
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

```text
$ touch outputs.tf
```

{% code title="terraform-workshops/iam/outputs.tf" %}
```bash
output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}
```
{% endcode %}

```text
$ terraform init
$ terraform apply

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

ec2_instance_profile_name = "terraform-workshops-ec2-profile"
```

{% code title="terraform-workshops/ec2-test-instances/main.tf" %}
```bash
@@ -22,6 +22,14 @@ data "terraform_remote_state" "vpc" {
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
 data "aws_ami" "ubuntu" {
   most_recent = true
 
@@ -83,6 +91,7 @@ resource "aws_instance" "public" {
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   vpc_security_group_ids = [aws_security_group.public_instances.id]
   subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
+  iam_instance_profile   = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name
 
   tags = {
     Name = "TerraformWorkshopsEC2InPublicSubnet"
@@ -95,6 +104,7 @@ resource "aws_instance" "private" {
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   vpc_security_group_ids = [aws_security_group.private_instances.id]
   subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_id
+  iam_instance_profile   = data.terraform_remote_state.iam.outputs.ec2_instance_profile_name
 
   tags = {
     Name = "TerraformWorkshopsEC2InPrivateSubnet"
```
{% endcode %}

```bash
ubuntu@ip-10-0-1-81:~$ sudo apt-get update

ubuntu@ip-10-0-1-81:~$ sudo apt-get install awscli

ubuntu@ip-10-0-1-81:~$ aws --version

ubuntu@ip-10-0-1-81:~$ aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:eu-central-1:852046301552:secret:db-secret-G7kbe9TbeCI=-sMOQ9J --region eu-central-1
```

