# 3. Virtual Private Cloud

Classless Inter-Domain Routing (CIDR) block is a notation that allows you to specify a range of IPv4 addresses for the VPC. Visit [cidr.xyz](https://cidr.xyz) to check how many IP addresses you will have available for a certain CIDR block.

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

Run `terraform init` and `terraform apply` commands to create a VPC, then go to VPC Dashboard on AWS Console to check what resources were created.

{% hint style="info" %}
Along with a new VPC the following resources are created:

* Main Route Table
* Network Access Control List
* Security Group
{% endhint %}

Create 4 subnets, 2 public and 2 private, 1 public and 1 private per 1 availability zone.

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

Apply changes and check subnet associations for the Main Route Table.

{% hint style="danger" %}
Subnets that are not explicitly associated with any route table are associated with the main route table. Never associate Internet Gateway with the Main Route Table to not expose your private resources by accident!
{% endhint %}

Let's explicitly make two subnets public. To do that we need to create a new Route Table and an Internet Gateway associated with it, and then associate subnets with the table.

{% code title="terraform/network/main.tf" %}
```bash
@@ -65,3 +65,30 @@ resource "aws_subnet" "private_subnet_b" {
     Name = "PrivateSubnetB"
   }
 }
+
+resource "aws_internet_gateway" "igw" {
+  vpc_id = aws_vpc.main.id
+
+  tags = {
+    "Name" = "TerraformWorkshopsInternetGateway"
+  }
+}
+
+resource "aws_route_table" "public_route" {
+  vpc_id = aws_vpc.main.id
+
+  route {
+    cidr_block = "0.0.0.0/0"
+    gateway_id = aws_internet_gateway.igw.id
+  }
+}
+
+resource "aws_route_table_association" "public_a_association" {
+  subnet_id      = aws_subnet.public_subnet_a.id
+  route_table_id = aws_route_table.public_route.id
+}
+
+resource "aws_route_table_association" "public_b_association" {
+  subnet_id      = aws_subnet.public_subnet_b.id
+  route_table_id = aws_route_table.public_route.id
+}
```
{% endcode %}

For now, the VPC configuration is ready. We need to test if it works correctly. For this purpose in `terraform` directory create `webserver-cluster` directory with `main.tf` file. At this point we will create a configuration required to test the VPC, later it will be transformed into a webserver cluster configuration.

{% code title="terraform/webserver-cluster/main.tf" %}
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

resource "aws_security_group" "public" {
  vpc_id = "???"

  ingress {
    description = "Allow SSH from everywhere"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic on all ports"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  vpc_id = "???"

  ingress {
    description     = "Allow SSH from EC2 in public subnet"
    protocol        = "tcp"
    from_port       = 22
    to_port         = 22
    security_groups = [aws_security_group.public.id]
  }

  egress {
    description = "Allow outbound traffic on all ports"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "my_ec2_key_pair" {
  key_name   = "my-ec2-key-pair"
  public_key = file("~/myEC2KeyPair.pub")
}

resource "aws_instance" "public" {
  ami                         = "ami-091f21ecba031b39a"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.my_ec2_key_pair.key_name
  subnet_id                   = "???"
  vpc_security_group_ids      = [aws_security_group.public.id]
  associate_public_ip_address = true
}

resource "aws_instance" "private" {
  ami                    = "ami-091f21ecba031b39a"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_ec2_key_pair.key_name
  subnet_id              = "???"
  vpc_security_group_ids = [aws_security_group.private.id]
}

```
{% endcode %}

We are missing `vpc_id` and two `subnet_id` values. Create the following outputs for the network module:

{% code title="terraform/network/outputs.tf" %}
```bash
output "vpc_id" {
  description = "The VPC Id"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public Subnets' Ids"
  value       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
}

output "private_subnet_ids" {
  description = "Private Subnets' Ids"
  value       = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

```
{% endcode %}

We need to get these values from the state file from the network directory. It can be done using `terraform_remote_state`.

{% code title="terraform/webserver-cluster/main.tf" %}
```bash
@@ -13,8 +13,20 @@ provider "aws" {
   region = "eu-central-1"
 }
 
+data "terraform_remote_state" "network" {
+  backend = "local"
+
+  config = {
+    "path" = "../network/terraform.tfstate"
+  }
+}
+
+locals {
+  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
+}
+
 resource "aws_security_group" "public" {
-  vpc_id = "???"
+  vpc_id = local.vpc_id
 
   ingress {
     description = "Allow SSH from everywhere"
@@ -34,7 +46,7 @@ resource "aws_security_group" "public" {
 }
 
 resource "aws_security_group" "private" {
-  vpc_id = "???"
+  vpc_id = local.vpc_id
 
   ingress {
     description     = "Allow SSH from EC2 in public subnet"
@@ -62,7 +74,7 @@ resource "aws_instance" "public" {
   ami                         = "ami-091f21ecba031b39a"
   instance_type               = "t2.micro"
   key_name                    = aws_key_pair.my_ec2_key_pair.key_name
-  subnet_id                   = "???"
+  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
   vpc_security_group_ids      = [aws_security_group.public.id]
   associate_public_ip_address = true
 }
@@ -71,6 +83,6 @@ resource "aws_instance" "private" {
   ami                    = "ami-091f21ecba031b39a"
   instance_type          = "t2.micro"
   key_name               = aws_key_pair.my_ec2_key_pair.key_name
-  subnet_id              = "???"
+  subnet_id              = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
   vpc_security_group_ids = [aws_security_group.private.id]
 }
```
{% endcode %}

Create outputs with IP addresses:

{% code title="terraform/webserver-cluster/outputs.tf" %}
```bash
output "public_ip_address" {
  value = aws_instance.public.public_ip
}

output "private_ip_address" {
  value = aws_instance.private.private_ip
}

```
{% endcode %}

Apply changes in `network` and then `webserver-cluster` directory.&#x20;

To be able to connect via ssh from the EC2 instance in the public subnet to the EC2 instance in the private subnet copy your private key to EC2 instances using `scp`.

```
$ scp -i ~/myEC2KeyPair ~/myEC2KeyPair ubuntu@35.156.147.217:~/myEC2KeyPair
```

Connect via ssh with the EC2 instance in the public subnet and execute the following command to check whether it has a route to the Internet.

```
$ sudo apt-get update
```

Next, connect to the EC2 instance in the private subnet and perform the same test.

{% hint style="danger" %}
To connect securely to EC2 instances in private subnets use Bastion Hosts. Do not use the presented way. It's not secure. We did this only for quick testing, resources will be destroyed soon.
{% endhint %}
