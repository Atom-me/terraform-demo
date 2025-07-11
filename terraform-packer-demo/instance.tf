resource "aws_instance" "example" {
  ami           = var.AMI_ID
  instance_type = "t2.micro"

  # Network configuration
  subnet_id                   = aws_subnet.main-public-1.id
  vpc_security_group_ids      = [aws_security_group.example-instance.id]
  associate_public_ip_address = true

  # SSH key configuration
  # (Optional) Key name of the Key Pair to use for the instance; which can be managed using the aws_key_pair resource.
  key_name = aws_key_pair.mykeypair.key_name

  # Root volume configuration
  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    encrypted   = true
    tags = {
      Name = "E2B-demo-root-volume"
    }
  }

  # # User data script
  # user_data = <<-EOF
  #             #!/bin/bash
  #             systemctl enable nginx
  #             systemctl start nginx
  #             EOF

  tags = {
    Name        = "E2B-demo-instance"
    Environment = "dev"
    Project     = "E2B"
    CreatedBy   = "terraform"
  }
}

