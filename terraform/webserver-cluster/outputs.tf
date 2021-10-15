output "public_ip_address" {
  value = aws_instance.public.public_ip
}

output "private_ip_address" {
  value = aws_instance.private.private_ip
}
