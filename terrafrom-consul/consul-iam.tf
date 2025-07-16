# IAM 角色用于 Consul EC2 实例
resource "aws_iam_role" "consul_instance_role" {
  name = "${var.prefix}-consul-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM 策略：Secrets Manager 访问权限
resource "aws_iam_policy" "consul_secrets_policy" {
  name        = "${var.prefix}-consul-secrets-policy"
  description = "Allow Consul instances to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.consul_acl_token.arn,
          aws_secretsmanager_secret.consul_gossip_encryption_key.arn,
          aws_secretsmanager_secret.consul_dns_request_token.arn
        ]
      }
    ]
  })

  tags = local.common_tags
}

# IAM 策略：EC2 Auto-Join 权限
resource "aws_iam_policy" "consul_ec2_policy" {
  name        = "${var.prefix}-consul-ec2-policy"
  description = "Allow Consul instances to discover other instances via EC2 tags"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

# 将策略附加到角色
resource "aws_iam_role_policy_attachment" "consul_secrets_policy_attachment" {
  role       = aws_iam_role.consul_instance_role.name
  policy_arn = aws_iam_policy.consul_secrets_policy.arn
}

resource "aws_iam_role_policy_attachment" "consul_ec2_policy_attachment" {
  role       = aws_iam_role.consul_instance_role.name
  policy_arn = aws_iam_policy.consul_ec2_policy.arn
}

# 创建实例配置文件
resource "aws_iam_instance_profile" "consul_instance_profile" {
  name = "${var.prefix}-consul-instance-profile"
  role = aws_iam_role.consul_instance_role.name

  tags = local.common_tags
} 