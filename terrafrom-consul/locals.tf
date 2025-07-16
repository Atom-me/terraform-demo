locals {
  server_count         = 3
  server_instance_type = "t2.large"
  client_count         = 2
  client_instance_type = "t2.medium"
  common_tags = {
    Project = "consul-cluster"
  }
} 