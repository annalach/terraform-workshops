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
