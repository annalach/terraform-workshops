output "instance_public_ip" {
  description = "Publi IP address of the EC2 instace"
  value       = aws_instance.web.public_ip
}
