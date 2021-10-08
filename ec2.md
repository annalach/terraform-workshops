# 2. Elastic Compute Cloud

During these workshops, we will use the default `local` backend. A backend is a place where the state of your infrastructure is stored.

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

In your root directory create `terraform` directory. Inside it, create `webserver` directory with `main.tf` file and add the following code to it:

{% code title="terraform/webserver/main.tf" %}
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

resource "aws_instance" "webserver" {
  ami           = "ami-091f21ecba031b39a"
  instance_type = "t2.micro"

  tags = {
    Name = "TerraformWorkshops"
  }
}
```
{% endcode %}

The `terraform {}` block contains settings, including AWS provider installed from [Terraform Registry](https://registry.terraform.io/). Providers are plugins that implement resource types. We will use AWS provider to create resources on AWS Cloud in `eu-central-1` region \(Europe, Frankfurt\).

In the `webserver` directory, run `terraform fmt` command to format the code.

```bash
$ terraform fmt
```

 Next, run `terraform init` command to install providers.

```bash
$ terraform init
```

Now you can use `terraform validate` command to validate the configuration

```bash
$ terraform validate
```

Once validation succeeded you can use `terraform plan` command to see what Terraform needs to do to achieve described infrastructure.

```bash
$ terraform plan
```

Run `terraform apply` command to deploy your resources. Verify displayed execution plan and type `yes` to confirm.

```bash
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.webserver will be created
  + resource "aws_instance" "webserver" {
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

aws_instance.webserver: Creating...
aws_instance.webserver: Still creating... [10s elapsed]
aws_instance.webserver: Still creating... [20s elapsed]
aws_instance.webserver: Creation complete after 25s [id=i-08839e4a788d49081]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Depending on the type of change you want to do, Terraform will perform an update in-place \(e.g tag change\) or destroy and then create a replacement \(e.g AMI change\).

{% code title="terraform/webserver/main.tf" %}
```bash
@@ -19,6 +19,6 @@ resource "aws_instance" "webserver" {
   instance_type = "t2.micro"
 
   tags = {
-    Name = "TerraformWorkshops"
+    Name = "TerraformWorkshops2021"
   }
 }
```
{% endcode %}

```bash
$ terraform plan

aws_instance.webserver: Refreshing state... [id=i-08839e4a788d49081]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # aws_instance.webserver will be updated in-place
  ~ resource "aws_instance" "webserver" {
        id                                   = "i-08839e4a788d49081"
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
```

{% code title="terraform/webserver/main.tf" %}
```bash
@@ -15,7 +15,7 @@ provider "aws" {
 }
 
 resource "aws_instance" "webserver" {
-  ami           = "ami-091f21ecba031b39a"
+  ami           = "ami-0db60716f1f6291f6"
   instance_type = "t2.micro"
 
   tags = {
```
{% endcode %}

```bash
$ terraform plan

aws_instance.webserver: Refreshing state... [id=i-08839e4a788d49081]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
-/+ destroy and then create replacement

Terraform will perform the following actions:

  # aws_instance.webserver must be replaced
-/+ resource "aws_instance" "webserver" {
      ~ ami                                  = "ami-091f21ecba031b39a" -> "ami-0db60716f1f6291f6" # forces replacement
      ~ arn                                  = "arn:aws:ec2:eu-central-1:852046301552:instance/i-08839e4a788d49081" -> (known after apply)
      ~ associate_public_ip_address          = true -> (known after apply)
      ~ availability_zone                    = "eu-central-1b" -> (known after apply)
      ~ cpu_core_count                       = 1 -> (known after apply)
      ~ cpu_threads_per_core                 = 1 -> (known after apply)
      ~ disable_api_termination              = false -> (known after apply)
      ~ ebs_optimized                        = false -> (known after apply)
      - hibernation                          = false -> null
      + host_id                              = (known after apply)
      ~ id                                   = "i-08839e4a788d49081" -> (known after apply)
      ~ instance_initiated_shutdown_behavior = "stop" -> (known after apply)
      ~ instance_state                       = "running" -> (known after apply)
      ~ ipv6_address_count                   = 0 -> (known after apply)
      ~ ipv6_addresses                       = [] -> (known after apply)
      + key_name                             = (known after apply)
      ~ monitoring                           = false -> (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      ~ primary_network_interface_id         = "eni-0c00d93c22f267d41" -> (known after apply)
      ~ private_dns                          = "ip-172-31-47-85.eu-central-1.compute.internal" -> (known after apply)
      ~ private_ip                           = "172.31.47.85" -> (known after apply)
      ~ public_dns                           = "ec2-3-64-124-13.eu-central-1.compute.amazonaws.com" -> (known after apply)
      ~ public_ip                            = "3.64.124.13" -> (known after apply)
      ~ secondary_private_ips                = [] -> (known after apply)
      ~ security_groups                      = [
          - "default",
        ] -> (known after apply)
      ~ subnet_id                            = "subnet-008b097c" -> (known after apply)
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
          ~ volume_id             = "vol-086579969b9b52122" -> (known after apply)
          ~ volume_size           = 8 -> (known after apply)
          ~ volume_type           = "gp2" -> (known after apply)
        }
    }

Plan: 1 to add, 0 to change, 1 to destroy.
```

Go to[ EC2 Dashboard on AWS Console](https://console.aws.amazon.com/ec2/v2/home?region=eu-central-1) to see created EC2 instance. 

{% hint style="info" %}
The EC2 instance is created in the default VPC and assigned to the default Security Group \(you can think about it as a virtual firewall\) that controls incoming and outgoing traffic. By default Security Group has rules that allow communication between resources in this Security Group.
{% endhint %}

Let's create SSH key pair and use it to connect to the EC2 instance.

```bash
$ ssh-keygen -t rsa -b 2048 -C "ubuntu" -m PEM -f ~/myEC2KeyPair
```

Make the following update to add key pair and security group with ingress and egress rules and use them with the EC2 instance:

{% code title="terraform/webserver/main.tf" %}
```bash
@@ -14,9 +14,44 @@ provider "aws" {
   region  = "eu-central-1"
 }
 
+resource "aws_security_group" "webserver" {
+  description = "Security group for webserver"
+
+  ingress {
+    description = "Allow SSH from everywhere"
+    protocol    = "tcp"
+    from_port   = 22
+    to_port     = 22
+    cidr_blocks = ["0.0.0.0/0"]
+  }
+
+  ingress {
+    description = "Allow inbound on port 5000"
+    protocol    = "tcp"
+    from_port   = 5000
+    to_port     = 5000
+    cidr_blocks = ["0.0.0.0/0"]
+  }
+
+  egress {
+    description = "Allow outboud traffic on all ports"
+    protocol    = "-1"
+    from_port   = 0
+    to_port     = 0
+    cidr_blocks = ["0.0.0.0/0"]
+  }
+}
+
+resource "aws_key_pair" "my_ec2_key_pair" {
+  key_name   = "my-ec2-key-pair"
+  public_key = file("~/myEC2KeyPair.pub")
+}
+
 resource "aws_instance" "webserver" {
-  ami           = "ami-091f21ecba031b39a"
-  instance_type = "t2.micro"
+  ami                    = "ami-091f21ecba031b39a"
+  instance_type          = "t2.micro"
+  key_name               = aws_key_pair.my_ec2_key_pair.key_name
+  vpc_security_group_ids = [aws_security_group.webserver.id]
 
   tags = {
     Name = "TerraformWorkshops"
```
{% endcode %}

Run `terraform apply` command to update your resources.

Once changes are done, go to AWS Console and find the public IP address of your instance and connect via SSH \(make sure to use your EC2 instance IP address instead of `3.120.139.14`\):

```bash
$ ssh -i ~/myEC2KeyPair ubuntu@3.120.139.14

Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-1017-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu Oct  7 20:23:51 UTC 2021

  System load:  0.08              Processes:             97
  Usage of /:   16.9% of 7.69GB   Users logged in:       0
  Memory usage: 19%               IPv4 address for eth0: 172.31.40.78
  Swap usage:   0%

1 update can be applied immediately.
To see these additional updates run: apt list --upgradable


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-172-31-40-78:~$
```

Verify if the instance can connect to the Internet by running `sudo apt-get update` command:

```bash
ubuntu@ip-172-31-40-78:~$ sudo apt-get update
```

Now let's fire up a simple webserver:

```bash
ubuntu@ip-172-31-40-78:~$ echo "Hello, World" > index.html
ubuntu@ip-172-31-40-78:~$ nohup busybox httpd -f -p 5000 &
```

From another terminal window use curl to send a GET request at the public IP address of your EC2 instance and port 5000:

```bash
$ curl http://3.120.139.14:5000
Hello, World
```

Exit EC2 instance:

```bash
ubuntu@ip-172-31-40-78:~$ exit
logout
Connection to 3.120.139.14 closed.
```

Let's make life easier and create:

* `variable` to define server port and use it in security group's ingress rule and user data script
*  `user_data` script that will fire up webserver when an EC2 instance is up
*  `output` that will give us a public IP address of an instance

{% code title="terraform/webserver/variables.tf" %}
```bash
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 5000
}
```
{% endcode %}

{% code title="terraform/webserver/main.tf" %}
```bash
@@ -28,8 +28,8 @@ resource "aws_security_group" "webserver" {
   ingress {
     description = "Allow inbound on port 5000"
     protocol    = "tcp"
-    from_port   = 5000
-    to_port     = 5000
+    from_port   = var.server_port
+    to_port     = var.server_port
     cidr_blocks = ["0.0.0.0/0"]
   }
 
@@ -53,6 +53,12 @@ resource "aws_instance" "webserver" {
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   vpc_security_group_ids = [aws_security_group.webserver.id]
 
+  user_data = <<-EOF
+              #!/bin/bash
+              echo "Hello, World" > index.html
+              nohup busybox httpd -f -p ${var.server_port} &
+              EOF
+
   tags = {
     Name = "TerraformWorkshops"
   }
```
{% endcode %}

{% code title="terraform/webserver/outputs.tf" %}
```bash
output "instance_public_ip" {
  description = "Publi IP address of the EC2 instace"
  value       = aws_instance.webserver.public_ip
}
```
{% endcode %}

Apply changes.

Next, we can polish the config by using:

* `data source` to get the latest Ubuntu Amazon Machine Image ID value
* `templatefile` function to move bash script to a separate file

{% code title="terraform/webserver/main.tf" %}
```bash
@@ -14,6 +14,22 @@ provider "aws" {
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
 resource "aws_security_group" "webserver" {
   description = "Security group for webserver"
 
@@ -48,16 +64,12 @@ resource "aws_key_pair" "my_ec2_key_pair" {
 }
 
 resource "aws_instance" "webserver" {
-  ami                    = "ami-091f21ecba031b39a"
+  ami                    = data.aws_ami.ubuntu.id
   instance_type          = "t2.micro"
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   vpc_security_group_ids = [aws_security_group.webserver.id]
 
-  user_data = <<-EOF
-              #!/bin/bash
-              echo "Hello, World" > index.html
-              nohup busybox httpd -f -p ${var.server_port} &
-              EOF
+  user_data = templatefile("./user_data.sh", { port = var.server_port })
 
   tags = {
     Name = "TerraformWorkshops"
```
{% endcode %}

{% code title="terraform/webserver/user\_data.sh" %}
```bash
#!/bin/bash
echo "Hello, World" > index.html
nohup busybox httpd -f -p ${port} &
```
{% endcode %}

Apply changes and verify if everything works. Run `terraform output` command to get the EC2 instance public IP address:

```bash
$ terraform output
```

To get a list of created resources run `terraform state list` command:

```bash
$ terraform state list
```

Finally, execute `terraform destroy` command in order to delete your resources.

```bash
$ terraform destroy
```

