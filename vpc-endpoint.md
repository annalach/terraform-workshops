# 6. VPC Endpoint

{% code title="terraform/vpc/mainf.tf" %}
```bash
@@ -19,7 +19,9 @@ data "aws_availability_zones" "available" {
 }
 
 resource "aws_vpc" "vpc" {
-  cidr_block = "10.0.0.0/16"
+  cidr_block           = "10.0.0.0/16"
+  enable_dns_support   = true
+  enable_dns_hostnames = true
 
   tags = {
     Name = "TerraformWorkshopsVPC"
@@ -72,3 +74,31 @@ resource "aws_route_table_association" "a" {
   subnet_id      = aws_subnet.public_subnet.id
   route_table_id = aws_route_table.public_route_table.id
 }
+
+resource "aws_security_group" "sm_vpc_endpoint" {
+  vpc_id      = aws_vpc.vpc.id
+  description = "Security Group for VPC Endpoint for Secrets Manager"
+
+  ingress {
+    description = "Allow HTTPS from EC2 instances from Private and Public Subnet"
+    protocol    = "tcp"
+    from_port   = 443
+    to_port     = 443
+    cidr_blocks = [aws_subnet.private_subnet.cidr_block, aws_subnet.public_subnet.cidr_block]
+  }
+}
+
+resource "aws_vpc_endpoint" "sm" {
+  vpc_id              = aws_vpc.vpc.id
+  service_name        = "com.amazonaws.eu-central-1.secretsmanager"
+  vpc_endpoint_type   = "Interface"
+  private_dns_enabled = true
+
+  security_group_ids = [
+    aws_security_group.sm_vpc_endpoint.id
+  ]
+
+  subnet_ids = [
+    aws_subnet.private_subnet.id
+  ]
+}
```
{% endcode %}

{% code title="terraform/ec2-test-instances/main.tf" %}
```bash
@@ -78,6 +78,14 @@ resource "aws_security_group" "private_instances" {
     to_port     = 22
     cidr_blocks = [data.terraform_remote_state.vpc.outputs.public_subnet_cidr_block]
   }
+
+  egress {
+    description = "Allow outboud traffic on all ports"
+    protocol    = "-1"
+    from_port   = 0
+    to_port     = 0
+    cidr_blocks = ["0.0.0.0/0"]
+  }
 }
 
 resource "aws_key_pair" "my_ec2_key_pair" {
```
{% endcode %}

The example code from this section is available [here](https://github.com/annalach/terraform-workshops/tree/vpc-endpoint/terraform-workshops).

