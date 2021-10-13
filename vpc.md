# 3. Virtual Private Cloud

Let's create a network for our infrastructure. In `terraform` directory , create `network` directory with `main.tf` file.

{% code title="terraform/network/main.tf" %}
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

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TerraformWorkshopsVPC"
  }
}
```
{% endcode %}

Run `terraform init` and `terraform apply` commands to create VPC, then go to[ VPC Dashboard](https://eu-central-1.console.aws.amazon.com/vpc) on AWS Console to check what resources were created.

{% hint style="info" %}
Along with a new VPC the following resources are created:

* Main Route Table
* Network Access Control List
* Security Group
{% endhint %}

Create 4 subnets, 2 public and 2 private, 1 public and 1 private in 1 availability zone.

{% code title="terraform/network/main.tf" %}
```bash
@@ -20,3 +20,48 @@ resource "aws_vpc" "main" {
     Name = "TerraformWorkshopsVPC"
   }
 }
+
+data "aws_availability_zones" "available" {
+  state = "available"
+}
+
+resource "aws_subnet" "public_subnet_a" {
+  vpc_id            = aws_vpc.main.id
+  availability_zone = data.aws_availability_zones.available.names[0]
+  cidr_block        = "10.0.1.0/24"
+
+  tags = {
+    Name = "PublicSubnetA"
+  }
+}
+
+resource "aws_subnet" "public_subnet_b" {
+  vpc_id            = aws_vpc.main.id
+  availability_zone = data.aws_availability_zones.available.names[1]
+  cidr_block        = "10.0.2.0/24"
+
+  tags = {
+    Name = "PublicSubnetB"
+  }
+}
+
+resource "aws_subnet" "private_subnet_a" {
+  vpc_id            = aws_vpc.main.id
+  availability_zone = data.aws_availability_zones.available.names[0]
+  cidr_block        = "10.0.3.0/24"
+
+  tags = {
+    Name = "PrivateSubnetA"
+  }
+
+}
+
+resource "aws_subnet" "private_subnet_b" {
+  vpc_id            = aws_vpc.main.id
+  availability_zone = data.aws_availability_zones.available.names[1]
+  cidr_block        = "10.0.4.0/24"
+
+  tags = {
+    Name = "PrivateSubnetB"
+  }
+}
```
{% endcode %}

Apply changes and check subnet associations for the main route table.

{% hint style="danger" %}
Subnets that are not explicitly associated with any route table are associated with the main route table!
{% endhint %}

{% code title="terraform/vpc/mainf.tf" %}
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

```
$ terraform apply
```

```
$ touch outputs.tf
```

{% code title="terraform/vpc/outputs.tf" %}
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

```bash
$ ssh-keygen -t rsa -b 2048 -C "ubuntu" -m PEM -f ~/myEC2KeyPair
```

## The terraform_remote_state Data Source

{% code title="terraform/ec2-test-instances/main.tf" %}
```bash
@@ -14,6 +14,14 @@ provider "aws" {
   region  = "eu-central-1"
 }
 
+data "terraform_remote_state" "vpc" {
+  backend = "local"
+
+  config = {
+    "path" = "../vpc/terraform.tfstate"
+  }
+}
+
 data "aws_ami" "ubuntu" {
   most_recent = true
```
{% endcode %}

{% code title="terraform/ec2-test-instances/main.tf" %}
```bash
@@ -39,6 +39,7 @@ data "aws_ami" "ubuntu" {
 }
 
 resource "aws_security_group" "public_instances" {
+  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
   description = "Security Group for instances in Public Subnet"
 
   ingress {
@@ -58,6 +59,19 @@ resource "aws_security_group" "public_instances" {
   }
 }
 
+resource "aws_security_group" "private_instances" {
+  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
+  description = "Security Group for instances in Private Subnet"
+
+  ingress {
+    description = "Allow SSH from EC2 instance from Public Subnet"
+    protocol    = "tcp"
+    from_port   = 22
+    to_port     = 22
+    cidr_blocks = [data.terraform_remote_state.vpc.outputs.public_subnet_cidr_block]
+  }
+}
+
 resource "aws_key_pair" "my_ec2_key_pair" {
   key_name   = "my-ec2-key-pair"
   public_key = file("~/myEC2KeyPair.pub")
@@ -68,12 +82,29 @@ resource "aws_instance" "public" {
   instance_type          = "t2.micro"
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
   vpc_security_group_ids = [aws_security_group.public_instances.id]
+  subnet_id              = data.terraform_remote_state.vpc.outputs.public_subnet_id
 
   tags = {
     Name = "TerraformWorkshopsEC2InPublicSubnet"
   }
 }
 
+resource "aws_instance" "private" {
+  ami                    = data.aws_ami.ubuntu.id
+  instance_type          = "t2.micro"
+  key_name               = aws_key_pair.my_ec2_key_pair.key_name
+  vpc_security_group_ids = [aws_security_group.private_instances.id]
+  subnet_id              = data.terraform_remote_state.vpc.outputs.private_subnet_id
+
+  tags = {
+    Name = "TerraformWorkshopsEC2InPrivateSubnet"
+  }
+}
+
 output "public_instance_public_ip" {
   value = aws_instance.public.public_ip
 }
+
+output "private_instance_private_ip" {
+  value = aws_instance.private.private_ip
+}
```
{% endcode %}

```bash
$ terraform apply

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

private_instance_private_ip = "10.0.2.83"
public_instance_public_ip = "35.156.147.217"
```

```bash
$ scp -i ~/myEC2KeyPair ~/myEC2KeyPair ubuntu@35.156.147.217:~/myEC2KeyPair
```

```bash
$ ssh -i ~/myEC2KeyPair ubuntu@35.156.147.217

Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-1017-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun Sep 19 08:26:17 UTC 2021

  System load:  0.0               Processes:             97
  Usage of /:   17.1% of 7.69GB   Users logged in:       0
  Memory usage: 19%               IPv4 address for eth0: 10.0.1.115
  Swap usage:   0%


1 update can be applied immediately.
To see these additional updates run: apt list --upgradable


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-10-0-1-115:~$ sudo apt-get update

ubuntu@ip-10-0-1-115:~$ ls
myEC2KeyPair

ubuntu@ip-10-0-1-115:~$ ssh -i ~/myEC2KeyPair ubuntu@10.0.2.83

Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.11.0-1017-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun Sep 19 08:28:48 UTC 2021

  System load:  0.0               Processes:             98
  Usage of /:   17.1% of 7.69GB   Users logged in:       0
  Memory usage: 19%               IPv4 address for eth0: 10.0.2.83
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

ubuntu@ip-10-0-2-83:~$ 

# this will fail because the instance does not have access to Internet
ubuntu@ip-10-0-2-83:~$ sudo apt-get update

ubuntu@ip-10-0-2-83:~$ exit
logout
Connection to 10.0.2.83 closed.

ubuntu@ip-10-0-1-115:~$ exit
logout
Connection to 35.156.147.217 closed.
```

The example code from this section is available [here](https://github.com/annalach/terraform-workshops/tree/vpc/terraform-workshops).
