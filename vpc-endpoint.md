# 6. VPC Endpoint

You can connect from VPC with Secrets Manager over the AWS network using VPC Endpoint.

{% code title="terraform/network/main.tf" %}
```bash
@@ -14,7 +14,8 @@ provider "aws" {
 }
 
 resource "aws_vpc" "main" {
-  cidr_block = "10.0.0.0/16"
+  cidr_block           = "10.0.0.0/16"
+  enable_dns_hostnames = true
 
   tags = {
     Name = "TerraformWorkshopsVPC"
@@ -92,3 +93,31 @@ resource "aws_route_table_association" "public_b_association" {
   subnet_id      = aws_subnet.public_subnet_b.id
   route_table_id = aws_route_table.public_route.id
 }
+
+resource "aws_security_group" "secrets_manager" {
+  vpc_id = aws_vpc.main.id
+
+  ingress {
+    description = "Allow HTTPS from the Private Subnet"
+    protocol    = "tcp"
+    from_port   = 443
+    to_port     = 443
+    cidr_blocks = [aws_subnet.private_subnet_a.cidr_block, aws_subnet.private_subnet_b.cidr_block]
+  }
+}
+
+resource "aws_vpc_endpoint" "secrets_manager" {
+  vpc_id              = aws_vpc.main.id
+  service_name        = "com.amazonaws.eu-central-1.secretsmanager"
+  vpc_endpoint_type   = "Interface"
+  private_dns_enabled = true
+
+  security_group_ids = [
+    aws_security_group.secrets_manager.id,
+  ]
+
+  subnet_ids = [
+    aws_subnet.private_subnet_a.id,
+    aws_subnet.private_subnet_b.id,
+  ]
+}
```
{% endcode %}

Test whether you can read the secret's value from the EC2 instance running in the private subnet.
