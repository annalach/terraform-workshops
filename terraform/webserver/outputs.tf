output "instance_public_ip" {
  description = "Publi IP address of the EC2 instace"
  value       = aws_instance.webserver.public_ip
}
