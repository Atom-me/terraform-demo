resource "aws_key_pair" "mykeypair" {
  key_name   = "atom-macbookpro-keypair"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
  
  tags = {
    Name        = "AgentSphere-demo-keypair"
    Environment = "dev"
    Project     = "AgentSphere"
  }
}

