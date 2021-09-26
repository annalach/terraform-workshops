output "vpc_id" {
  description = "The VPC Id"
  value       = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  value       = aws_subnet.public_subnets.*.id
  description = "Public Subnets' Ids"
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnets.*.id
  description = "Private Subnets' Ids"
}

output "public_subnets_cidr_blocks" {
  value       = aws_subnet.public_subnets.*.cidr_block
  description = "Public Subnets' CIDR blocks"
}

output "private_subnets_cidr_blocks" {
  value       = aws_subnet.private_subnets.*.cidr_block
  description = "Private Subnets' CIDR blocks"
}
