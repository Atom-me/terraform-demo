// Consul 高可用集群（3 Server + 2 Client）

// 使用 aws_instance + file provisioner 直接上传脚本并启动 Consul 集群

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "consul-cluster"
      Environment = "atom-demo"
      ManagedBy   = "terraform"
    }
  }
} 