locals {
  server_count         = 3
  server_instance_type = "t3.medium"
  client_count         = 2
  client_instance_type = "t3.small"
  common_tags = {
    Project = "consul-cluster"
  }
} 