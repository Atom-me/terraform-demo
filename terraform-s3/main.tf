
# 获取当前 AWS 账号和区域信息，便于资源唯一性和自动化命名
# data 资源不会创建实际资源，只是读取当前环境信息
# 用于后续 locals、资源命名、标签等

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Terraform 基础配置，指定所需版本和 Provider 版本，保证团队环境一致性
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# AWS Provider 配置，支持通过变量灵活切换账号和区域
# 适合多环境/多账号/多区域场景，便于团队协作和自动化
provider "aws" {
  region  = var.aws_region   # 区域参数，优先级：命令行 > setup.config > 默认值
  profile = var.aws_profile # 账号参数，优先级同上
}

# 本地变量定义（locals），用于统一管理脚本哈希、标签、账号ID等
locals {
  # 当前 AWS 账号 ID，便于资源命名唯一性
  account_id = data.aws_caller_identity.current.account_id

  # 当前 AWS 区域，推荐用 id 属性（name 已废弃）
  aws_region = data.aws_region.current.id

  # 计算每个脚本文件的 SHA256 哈希值（取前5位），用于 S3 对象命名，实现“内容变更即新版本”
  # 这样每次脚本内容变化，S3 对象名也会变化，便于版本管理和缓存失效
  file_hash = {
    "scripts/run-consul.sh"              = substr(filesha256("${path.module}/scripts/run-consul.sh"), 0, 5)
    "scripts/run-nomad.sh"               = substr(filesha256("${path.module}/scripts/run-nomad.sh"), 0, 5)
    "scripts/run-api-nomad.sh"           = substr(filesha256("${path.module}/scripts/run-api-nomad.sh"), 0, 5)
    "scripts/run-build-cluster-nomad.sh" = substr(filesha256("${path.module}/scripts/run-build-cluster-nomad.sh"), 0, 5)
  }

  # 统一资源标签，便于后续在 AWS 控制台筛选、成本归集、权限管理等
  # 建议所有资源都打上 Environment/Project/Owner/ManagedBy 等标签
  common_tags = {
    Environment = "Production"   # 环境标识，可按需调整为 dev/test/prod
    Project     = "test-Project" # 项目名称
    Owner       = "DevOps"       # 负责人或团队
    ManagedBy   = "Terraform"    # 标记资源由 Terraform 管理
  }
}

# S3 Bucket 资源定义，用于存放所有初始化脚本
# 桶名格式：<prefix>-cluster-setup-<account_id>，保证全局唯一且易于识别
# tags 统一打标签，便于后续管理
resource "aws_s3_bucket" "setup_bucket" {
  bucket = "${var.prefix}-cluster-setup-${local.account_id}"
  tags   = local.common_tags
}

# 定义需要上传的本地脚本文件及其 S3 对象前缀
# key 为本地文件路径，value 为 S3 对象前缀
# 便于后续批量上传和命名
variable "setup_files" {
  type = map(string)
  default = {
    "scripts/run-nomad.sh"               = "run-nomad",
    "scripts/run-api-nomad.sh"           = "run-api-nomad",
    "scripts/run-build-cluster-nomad.sh" = "run-build-cluster-nomad",
    "scripts/run-consul.sh"              = "run-consul"
  }
}

# 批量上传脚本到 S3，每个对象名带有内容哈希，便于版本区分和缓存失效
# for_each 遍历 setup_files，自动生成多个 S3 对象
# key 格式：<前缀>-<哈希>.sh，如 run-nomad-abc12.sh
# etag 用于 S3 对象内容校验，防止重复上传
resource "aws_s3_object" "setup_config_objects" {
  for_each = var.setup_files
  bucket   = aws_s3_bucket.setup_bucket.bucket
  key      = "${each.value}-${local.file_hash[each.key]}.sh"
  source   = "${path.module}/${each.key}"
  etag     = filemd5("${path.module}/${each.key}")
}

# 输出 S3 桶名，便于后续脚本或人查看
output "bucket_name" {
  value = aws_s3_bucket.setup_bucket.bucket
}

# 输出所有上传对象的 key，便于查找和后续自动化
output "object_keys" {
  value = {
    for k, v in aws_s3_object.setup_config_objects : k => v.key
  }
}

# 输出所有脚本的哈希值，便于比对和调试
output "file_hashes" {
  value = local.file_hash
} 