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
