# 2. Elastic Compute Cloud

## Terraform Basics

During these workshops, you will use the default `local` backend. A backend is a place where:

* the state of your infrastructure is stored,
* operations are performed.

 The state is kept in JSON format in a file with `tfstate` extension. It stores all information about your infrastructure, including **sensitive data** like database credentials. Due to this fact, the state shouldn't be kept in a version control system. 

Create a directory on your computer for these workshops. I will refer to this directory as a **root directory**. Inside it, create `.gitignore` file with the following content:

{% code title=".gitignore" %}
```bash
.terraform
*.tfstate
*.tfstate.lock.info
*.tfstate.backup

```
{% endcode %}

Besides the state files, I want you to ignore `.terraform` directories Terraform will create. You can think about it like `node_modules` in a JavaScript project. It stores the dependencies required by your project. Like NPM creates a `package-lock.json` file to represent the dependencies you declared, Terraform will create `.terraform.lock.hcl` file you should keep in your VCS.

{% code title="terraform/ec2/mainf.tf" %}
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

resource "aws_instance" "web" {
  ami           = "ami-091f21ecba031b39a"
  instance_type = "t2.micro"

  tags = {
    Name = "TerraformWorkshops"
  }
}
```
{% endcode %}

### Commands

```bash
$ terraform init
```

```bash
$ terraform fmt
```

```bash
$ terraform validate
```

```bash
$ terraform plan
```

```bash
$ terraform apply
```

```bash
$ terraform state list
```

```bash
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the
following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-091f21ecba031b39a"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "TerraformWorkshops"
        }
      + tags_all                             = {
          + "Name" = "TerraformWorkshops"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Still creating... [20s elapsed]
aws_instance.web: Still creating... [30s elapsed]
aws_instance.web: Creation complete after 35s [id=i-0090a8e6cfe9585c6]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

{% code title="terraform/ec2/main.tf" %}
```bash
@@ -19,6 +19,6 @@ resource "aws_instance" "web" {
   instance_type = "t2.micro"
 
   tags = {
-    Name = "TerraformWorkshops"
+    Name = "TerraformWorkshops2021"
   }
 }
```
{% endcode %}

```bash
$ terraform apply

aws_instance.web: Refreshing state... [id=i-0090a8e6cfe9585c6]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.web will be updated in-place
  ~ resource "aws_instance" "web" {
        id                                   = "i-0090a8e6cfe9585c6"
      ~ tags                                 = {
          ~ "Name" = "TerraformWorkshops" -> "TerraformWorkshops2021"
        }
      ~ tags_all                             = {
          ~ "Name" = "TerraformWorkshops" -> "TerraformWorkshops2021"
        }
        # (27 unchanged attributes hidden)





        # (5 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

{% code title="terraform/ec2/main.tf" %}
```bash
@@ -15,7 +15,7 @@ provider "aws" {
 }
 
 resource "aws_instance" "web" {
-  ami           = "ami-091f21ecba031b39a"
+  ami           = "ami-0db60716f1f6291f6"
   instance_type = "t2.micro"
 
   tags = {
```
{% endcode %}

```bash
$ terraform apply

aws_instance.web: Refreshing state... [id=i-0090a8e6cfe9585c6]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_instance.web must be replaced
-/+ resource "aws_instance" "web" {
      ~ ami                                  = "ami-091f21ecba031b39a" -> "ami-0db60716f1f6291f6" # forces replacement
      ~ arn                                  = "arn:aws:ec2:eu-central-1:852046301552:instance/i-0090a8e6cfe9585c6" -> (known after apply)
      ~ associate_public_ip_address          = true -> (known after apply)
      ~ availability_zone                    = "eu-central-1c" -> (known after apply)
      ~ cpu_core_count                       = 1 -> (known after apply)
      ~ cpu_threads_per_core                 = 1 -> (known after apply)
      ~ disable_api_termination              = false -> (known after apply)
      ~ ebs_optimized                        = false -> (known after apply)
      - hibernation                          = false -> null
      + host_id                              = (known after apply)
      ~ id                                   = "i-0090a8e6cfe9585c6" -> (known after apply)
      ~ instance_initiated_shutdown_behavior = "stop" -> (known after apply)
      ~ instance_state                       = "running" -> (known after apply)
      ~ ipv6_address_count                   = 0 -> (known after apply)
      ~ ipv6_addresses                       = [] -> (known after apply)
      + key_name                             = (known after apply)
      ~ monitoring                           = false -> (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      ~ primary_network_interface_id         = "eni-0b6e156a8fff620fb" -> (known after apply)
      ~ private_dns                          = "ip-172-31-12-110.eu-central-1.compute.internal" -> (known after apply)
      ~ private_ip                           = "172.31.12.110" -> (known after apply)
      ~ public_dns                           = "ec2-35-158-107-0.eu-central-1.compute.amazonaws.com" -> (known after apply)
      ~ public_ip                            = "35.158.107.0" -> (known after apply)
      ~ secondary_private_ips                = [] -> (known after apply)
      ~ security_groups                      = [
          - "default",
        ] -> (known after apply)
      ~ subnet_id                            = "subnet-5959c815" -> (known after apply)
        tags                                 = {
            "Name" = "TerraformWorkshops"
        }
      ~ tenancy                              = "default" -> (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      ~ vpc_security_group_ids               = [
          - "sg-181f6d6f",
        ] -> (known after apply)
        # (4 unchanged attributes hidden)

      ~ capacity_reservation_specification {
          ~ capacity_reservation_preference = "open" -> (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      - credit_specification {
          - cpu_credits = "standard" -> null
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      ~ enclave_options {
          ~ enabled = false -> (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      ~ metadata_options {
          ~ http_endpoint               = "enabled" -> (known after apply)
          ~ http_put_response_hop_limit = 1 -> (known after apply)
          ~ http_tokens                 = "optional" -> (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      ~ root_block_device {
          ~ delete_on_termination = true -> (known after apply)
          ~ device_name           = "/dev/sda1" -> (known after apply)
          ~ encrypted             = false -> (known after apply)
          ~ iops                  = 100 -> (known after apply)
          + kms_key_id            = (known after apply)
          ~ tags                  = {} -> (known after apply)
          ~ throughput            = 0 -> (known after apply)
          ~ volume_id             = "vol-081b37c28bbaaf1c6" -> (known after apply)
          ~ volume_size           = 8 -> (known after apply)
          ~ volume_type           = "gp2" -> (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

```bash
$ terraform destroy
```

```bash
aws_instance.web: Refreshing state... [id=i-0090a8e6cfe9585c6]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  - destroy

Terraform will perform the following actions:

  # aws_instance.web will be destroyed
  - resource "aws_instance" "web" {
      - ami                                  = "ami-091f21ecba031b39a" -> null
      - arn                                  = "arn:aws:ec2:eu-central-1:852046301552:instance/i-0090a8e6cfe9585c6" -> null
      - associate_public_ip_address          = true -> null
      - availability_zone                    = "eu-central-1c" -> null
      - cpu_core_count                       = 1 -> null
      - cpu_threads_per_core                 = 1 -> null
      - disable_api_termination              = false -> null
      - ebs_optimized                        = false -> null
      - get_password_data                    = false -> null
      - hibernation                          = false -> null
      - id                                   = "i-0090a8e6cfe9585c6" -> null
      - instance_initiated_shutdown_behavior = "stop" -> null
      - instance_state                       = "running" -> null
      - instance_type                        = "t2.micro" -> null
      - ipv6_address_count                   = 0 -> null
      - ipv6_addresses                       = [] -> null
      - monitoring                           = false -> null
      - primary_network_interface_id         = "eni-0b6e156a8fff620fb" -> null
      - private_dns                          = "ip-172-31-12-110.eu-central-1.compute.internal" -> null
      - private_ip                           = "172.31.12.110" -> null
      - public_dns                           = "ec2-35-158-107-0.eu-central-1.compute.amazonaws.com" -> null
      - public_ip                            = "35.158.107.0" -> null
      - secondary_private_ips                = [] -> null
      - security_groups                      = [
          - "default",
        ] -> null
      - source_dest_check                    = true -> null
      - subnet_id                            = "subnet-5959c815" -> null
      - tags                                 = {
          - "Name" = "TerraformWorkshops"
        } -> null
      - tags_all                             = {
          - "Name" = "TerraformWorkshops"
        } -> null
      - tenancy                              = "default" -> null
      - vpc_security_group_ids               = [
          - "sg-181f6d6f",
        ] -> null

      - capacity_reservation_specification {
          - capacity_reservation_preference = "open" -> null
        }

      - credit_specification {
          - cpu_credits = "standard" -> null
        }

      - enclave_options {
          - enabled = false -> null
        }

      - metadata_options {
          - http_endpoint               = "enabled" -> null
          - http_put_response_hop_limit = 1 -> null
          - http_tokens                 = "optional" -> null
        }

      - root_block_device {
          - delete_on_termination = true -> null
          - device_name           = "/dev/sda1" -> null
          - encrypted             = false -> null
          - iops                  = 100 -> null
          - tags                  = {} -> null
          - throughput            = 0 -> null
          - volume_id             = "vol-081b37c28bbaaf1c6" -> null
          - volume_size           = 8 -> null
          - volume_type           = "gp2" -> null
        }
    }

Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

aws_instance.web: Destroying... [id=i-0090a8e6cfe9585c6]
aws_instance.web: Still destroying... [id=i-0090a8e6cfe9585c6, 10s elapsed]
aws_instance.web: Still destroying... [id=i-0090a8e6cfe9585c6, 20s elapsed]
aws_instance.web: Still destroying... [id=i-0090a8e6cfe9585c6, 30s elapsed]
aws_instance.web: Destruction complete after 31s

Destroy complete! Resources: 1 destroyed.
```

### Variables

{% code title="terraform/ec2/variables.tf" %}
```bash
variable "instance_name" {
  description = "Value of the Name tag for the EC instance"
  type        = string
  default     = "TerraformWorkshops"
}
```
{% endcode %}

{% code title="terraform/ec2/main.tf" %}
```bash
@@ -19,6 +19,6 @@ resource "aws_instance" "web" {
   instance_type = "t2.micro"
 
   tags = {
-    Name = "TerraformWorkshops"
+    Name = var.instance_name
   }
 }
```
{% endcode %}

### Data Sources

```bash
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
```

{% code title="terraform/ec2/main.tf" %}
```bash
@@ -14,8 +14,24 @@ provider "aws" {
   region  = "eu-central-1"
 }
 
+data "aws_ami" "ubuntu" {
+  most_recent = true
+
+  filter {
+    name   = "name"
+    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
+  }
+
+  filter {
+    name   = "virtualization-type"
+    values = ["hvm"]
+  }
+
+  owners = ["099720109477"] # Canonical
+}
+
 resource "aws_instance" "web" {
-  ami           = "ami-091f21ecba031b39a"
+  ami           = data.aws_ami.ubuntu.id
   instance_type = "t2.micro"
 
   tags = {
```
{% endcode %}

### Outputs

```bash
$ touch outputs.tf
```

{% code title="terraform/ec2/outputs.tf" %}
```bash
output "instance_public_ip" {
  description = "Publi IP address of the EC2 instace"
  value       = aws_instance.web.public_ip
}
```
{% endcode %}

## Simple Web Server

{% code title="terraform/ec2/variables.tf" %}
```bash
@@ -3,3 +3,9 @@ variable "instance_name" {
   type        = string
   default     = "TerraformWorkshops"
 }
+
+variable "server_port" {
+  description = "The port the server will use for HTTP requests"
+  type        = number
+  default     = 5000
+}
```
{% endcode %}

{% code title="terraform/ec2/main.tf" %}
```bash
@@ -30,9 +30,28 @@ data "aws_ami" "ubuntu" {
   owners = ["099720109477"] # Canonical
 }
 
+resource "aws_security_group" "web" {
+
+  ingress {
+    from_port   = var.server_port
+    to_port     = var.server_port
+    protocol    = "tcp"
+    cidr_blocks = ["0.0.0.0/0"]
+  }
+
+}
+
 resource "aws_instance" "web" {
   ami                    = data.aws_ami.ubuntu.id
   instance_type          = "t2.micro"
+  vpc_security_group_ids = [aws_security_group.web.id]
+
+  user_data = <<-EOF
+              #!/bin/bash
+              echo "Hello, World" > index.html
+              nohup busybox httpd -f -p ${var.server_port} &
+              EOF
+
 
   tags = {
     Name = var.instance_name
```
{% endcode %}

```bash
$ terraform apply --auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.web will be created
  + resource "aws_instance" "web" {
      + ami                                  = "ami-091f21ecba031b39a"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "TerraformWorkshops"
        }
      + tags_all                             = {
          + "Name" = "TerraformWorkshops"
        }
      + tenancy                              = (known after apply)
      + user_data                            = "5ab9f442a5001c89c3e281e3538db613cfff5950"
      + user_data_base64                     = (known after apply)
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = (known after apply)
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_security_group.web will be created
  + resource "aws_security_group" "web" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 5000
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 5000
            },
        ]
      + name                   = (known after apply)
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + instance_public_ip = (known after apply)
aws_security_group.web: Creating...
aws_security_group.web: Creation complete after 3s [id=sg-012b448a85576b023]
aws_instance.web: Creating...
aws_instance.web: Still creating... [10s elapsed]
aws_instance.web: Still creating... [20s elapsed]
aws_instance.web: Creation complete after 25s [id=i-0a7d753a4dd3bde46]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

instance_public_ip = "3.68.88.93"
```

```bash
$ curl http://3.68.88.93:5000
Hello, World
```

```bash
$ terraform output
```

```bash
$ touch user_data.sh
```

{% code title="terraform/ec2/user\_data.sh" %}
```bash
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p ${port} &
```
{% endcode %}

[templatefile](https://www.terraform.io/docs/language/functions/templatefile.html) function

{% code title="terraform/ec2/main.tf" %}
```bash
@@ -46,12 +46,7 @@ resource "aws_instance" "web" {
   instance_type          = "t2.micro"
   vpc_security_group_ids = [aws_security_group.web.id]
 
-  user_data = <<-EOF
-              #!/bin/bash
-              echo "Hello, World" > index.html
-              nohup busybox httpd -f -p ${var.server_port} &
-              EOF
-
+  user_data = templatefile("./user_data.sh", { port = var.server_port })
 
   tags = {
     Name = var.instance_name
```
{% endcode %}

