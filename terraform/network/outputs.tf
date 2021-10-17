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

output "private_subnets_cidr_blocks" {
  description = "Private Subnets' CIDR blocks"
  value       = [aws_subnet.private_subnet_a.cidr_block, aws_subnet.private_subnet_b.cidr_block]
}
