# Instance Information
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.example.public_dns
}

# Network Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.main-public-1.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.example-instance.id
}

# SSH Information
output "ssh_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ${var.PATH_TO_PRIVATE_KEY} ubuntu@${aws_instance.example.public_ip}"
}

# Web Access
output "nginx_url" {
  description = "URL to access nginx web server"
  value       = "http://${aws_instance.example.public_ip}"
}

# AMI Information
output "ami_id" {
  description = "AMI ID used for the instance"
  value       = var.AMI_ID
} 