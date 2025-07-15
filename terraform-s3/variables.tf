// AWS 区域参数，支持通过 Makefile/setup.config/命令行传递
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

// AWS 账号 profile 参数，支持多账号切换
variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"
}

// 预留环境变量参数，可扩展
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "test"
}

# Resource Prefix
# Used to name and tag all resources created by Terraform
variable "prefix" {
  description = "Prefix of Resource"
  type        = string
  default     = "atom-test-tf"
}