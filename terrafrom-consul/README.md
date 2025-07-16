# Consul 高可用集群

基于 Terraform 和 AWS 的生产级 Consul 高可用集群部署方案。

## 🏗️ 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS VPC                              │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                    Public Subnet                        │ │
│  │                                                         │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │ │
│  │  │Consul Server │  │Consul Server │  │Consul Server │  │ │
│  │  │   (Leader)   │  │  (Follower)  │  │  (Follower)  │  │ │
│  │  │  t3.medium   │  │  t3.medium   │  │  t3.medium   │  │ │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  │ │
│  │                                                         │ │
│  │  ┌──────────────┐  ┌──────────────┐                    │ │
│  │  │Consul Client │  │Consul Client │                    │ │
│  │  │   t3.small   │  │   t3.small   │                    │ │
│  │  └──────────────┘  └──────────────┘                    │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### 集群特性

- **高可用**: 3 个 Server 节点，支持 1 个节点故障
- **自动发现**: 基于 AWS 标签的 Cloud Auto-Join
- **安全通信**: ACL + Gossip 加密
- **服务发现**: 支持 DNS 和 HTTP API
- **Web UI**: 8500 端口提供管理界面
- **动态配置**: 自动检测网络接口和AWS区域

## 📋 系统要求

- **Terraform**: >= 1.0
- **AWS CLI**: 已配置凭证
- **SSH Key**: 用于实例访问
- **权限**: EC2、VPC、Secrets Manager

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd terrafrom-consul
```

### 2. 配置参数

有两种方式配置参数：

**方式1: 通过 setup.config 文件（推荐）**

```bash
# 创建配置文件
make setup

# 编辑配置文件
vim setup.config
```

`setup.config` 示例：
```bash
# AWS 配置
AWS_PROFILE=atom
AWS_REGION=us-east-1

# 项目配置  
PREFIX=my-consul
KEY_NAME=my-key-pair

# SSH 配置
SSH_PRIVATE_KEY=~/.ssh/id_rsa
SSH_PUBLIC_KEY=~/.ssh/id_rsa.pub
```

**方式2: 通过命令行参数**

```bash
# 查看帮助和当前配置
make help

# 指定自定义参数部署
make apply PREFIX=test REGION=us-west-2 AWS_PROFILE=production KEY_NAME=my-key
```

### 3. 部署集群

```bash
# 创建配置文件（首次使用）
make setup

# 编辑 setup.config 设置您的参数
vim setup.config

# 开发环境一键部署
make dev-deploy

# 或者指定参数部署（覆盖 setup.config）
make dev-deploy PREFIX=test AWS_PROFILE=dev REGION=us-west-2

# 分步部署
make init
make plan
make apply
```

### 4. 验证部署

```bash
# 查看集群状态
make consul-status

# 测试免密登录
make test-ssh

# 打开 Web UI（如果浏览器未自动打开，请手动访问输出的URL）
make ui

# SSH 到节点（免密登录）
make ssh-server
```

### 5. 清理资源

```bash
# 销毁集群（推荐，自动清理 Secrets）
make destroy

# 彻底清理所有资源和本地文件
make clean-all

# 仅清理 AWS Secrets Manager 资源
make clean-secrets
```

## 🛠️ 常用命令示例

### 多环境管理

```bash
# 开发环境
make apply PREFIX=dev AWS_PROFILE=dev-account REGION=us-east-1

# 测试环境  
make apply PREFIX=test AWS_PROFILE=test-account REGION=us-west-2

# 生产环境
make apply PREFIX=prod AWS_PROFILE=prod-account REGION=ap-northeast-1

# 查看不同环境
make consul-status PREFIX=dev AWS_PROFILE=dev-account
make consul-status PREFIX=prod AWS_PROFILE=prod-account
```

### 集群管理

```bash
# 销毁指定环境（自动清理 Secrets）
make destroy PREFIX=test AWS_PROFILE=test-account

# 查看计划（不执行）
make plan PREFIX=prod AWS_PROFILE=prod-account

# 查看日志
make logs-server PREFIX=dev AWS_PROFILE=dev-account
make logs-client PREFIX=dev AWS_PROFILE=dev-account

# 测试免密登录
make test-ssh PREFIX=prod AWS_PROFILE=prod-account

# 强制清理 Secrets Manager 资源
make clean-secrets PREFIX=test AWS_PROFILE=test-account

# 彻底清理所有资源
make clean-all PREFIX=test AWS_PROFILE=test-account
```

## 📁 项目结构

```
terrafrom-consul/
├── main.tf                    # 入口文件  
├── locals.tf                  # 本地变量
├── variables.tf               # 输入变量
├── outputs.tf                 # 输出变量
├── vpc.tf                     # VPC 网络
├── sg.tf                      # 安全组
├── consul-secrets.tf          # Consul 密钥
├── consul-iam.tf              # IAM 角色和策略
├── consul-ec2.tf              # EC2 实例
├── scripts/                   # User-data 脚本
│   ├── user-data-server.sh    # 服务器节点启动脚本
│   └── user-data-client.sh    # 客户端节点启动脚本
├── Makefile                   # 管理命令
├── setup.config               # 配置文件（用户创建）
├── setup.config.example       # 配置模板
├── .gitignore                 # Git 忽略文件
└── README.md                  # 项目文档
```

## ⚙️ 配置说明

### 变量配置

| 变量 | 描述 | 默认值 | 必需 |
|------|------|--------|------|
| `prefix` | 资源名称前缀 | - | ✅ |
| `region` | AWS 区域 | - | ✅ |
| `aws_profile` | AWS Profile | `default` | ❌ |
| `key_name` | SSH Key Pair 名称 | - | ✅ |
| `ssh_private_key` | SSH 私钥路径 | - | ✅ |
| `ssh_public_key` | SSH 公钥路径（免密登录） | `~/.ssh/id_rsa.pub` | ❌ |

### 集群配置

在 `locals.tf` 中可调整：

```hcl
locals {
  server_count = 3              # Server 节点数（推荐奇数）
  server_instance_type = "t3.medium"  # 已优化的实例类型
  client_count = 2              # Client 节点数（已启用）
  client_instance_type = "t3.small"   # 成本优化的实例类型
}
```

### 网络配置

- **VPC CIDR**: `10.0.0.0/16`
- **子网 CIDR**: `10.0.1.0/24`
- **端口开放**: 22, 8300-8302, 8500, 8600

### SSH 免密登录设置

系统会自动将您的公钥上传到所有节点，实现免密登录：

1. **自动配置**: 部署时自动上传公钥到 `~/.ssh/authorized_keys`
2. **权限设置**: 自动设置正确的文件权限（700/600）
3. **去重处理**: 避免重复添加相同的公钥
4. **测试验证**: 使用 `make test-ssh` 验证免密登录

**要求**:
- 确保 `ssh_public_key` 路径指向有效的公钥文件
- 默认使用 `~/.ssh/id_rsa.pub`，可通过参数自定义

## 🔄 部署流程

### 资源创建顺序

1. **网络基础** - VPC、子网、网关、路由表
2. **安全组** - Consul 端口规则
3. **IAM 角色** - EC2实例权限和Secrets Manager访问
4. **密钥管理** - ACL Token、Gossip Key
5. **Server 节点** - 3 个 Consul Server (user-data 自动配置)
6. **Client 节点** - 2 个 Consul Client (user-data 自动配置)

### 启动流程

1. **依赖安装** - Consul、bash-commons、工具
2. **动态配置** - 自动检测私有IP和AWS区域
3. **密钥获取** - 从Secrets Manager获取Gossip Key
4. **Consul 启动** - 自动配置和启动
5. **集群形成** - Cloud Auto-Join 发现
6. **ACL 初始化** - Leader 节点执行

## 🛠️ 管理命令

### 基础操作

```bash
make help           # 显示帮助
make init           # 初始化 Terraform
make plan           # 生成执行计划
make apply          # 部署集群
make destroy        # 销毁集群
```

### 集群管理

```bash
make status         # 查看基础状态
make consul-status  # 查看 Consul 集群
make ui             # 打开 Web UI
make ssh-server     # SSH 到 Server
make ssh-client     # SSH 到 Client
```

### 日志查看

```bash
make logs-server    # Server 日志
make logs-client    # Client 日志
```

### 开发/生产

```bash
make dev-deploy     # 开发环境部署
make prod-deploy    # 生产环境部署（需确认）
```

## 🔍 故障排查

### 常见问题及解决方案

#### 1. 实例无法启动

**症状**: EC2 实例创建失败

**排查**:
```bash
# 检查配置
terraform validate
terraform plan

# 查看错误信息
terraform apply
```

**解决**:
- 检查 AMI 在指定区域是否可用
- 确认 SSH Key Pair 存在
- 检查 AWS 权限和配额

#### 2. Consul 服务未启动

**症状**: SSH 到实例后 `consul members` 失败

**排查**:
```bash
# SSH 到节点
make ssh-server

# 检查服务状态
sudo systemctl status consul.service

# 查看日志
sudo journalctl -u consul.service -f

# 检查配置文件
sudo cat /etc/consul.d/server.json | jq '.'
```

**解决**:
- 检查依赖是否安装完成
- 验证网络连通性（8300-8302 端口）
- 查看 `/opt/consul/bin/` 下脚本权限
- 检查bind_addr是否为有效IP（非模板字符串）

#### 3. 集群无法形成

**症状**: `consul members` 只显示单个节点

**排查**:
```bash
# 检查自动发现配置
sudo cat /etc/consul.d/server.json | jq '.retry_join'

# 检查 AWS 标签
aws ec2 describe-instances --filters "Name=tag:consul-cluster,Values=server-cluster"

# 检查 IAM 权限
aws sts get-caller-identity
```

**解决**:
- 确认所有实例有正确的标签
- 检查 IAM 权限（EC2 describe-instances）
- 验证安全组规则（8300-8302端口）

#### 4. Gossip 加密密钥为空

**症状**: 配置文件中 `"encrypt": ""` 为空

**排查**:
```bash
# 检查 Secrets Manager
aws secretsmanager get-secret-value --secret-id [SECRET_NAME]

# 检查 IAM 权限
aws iam get-role --role-name [IAM_ROLE_NAME]
```

**解决**:
- 确认 Secrets Manager 中密钥存在
- 检查 IAM 角色有 secretsmanager:GetSecretValue 权限
- 验证实例可以访问 Secrets Manager API

#### 5. ACL 初始化失败

**症状**: Consul UI 显示无权限

**排查**:
```bash
# 检查 Leader 节点
consul operator raft list-peers

# 查看 ACL 状态
consul acl bootstrap
```

**解决**:
- 确保只有 Leader 执行 bootstrap
- 检查密钥配置是否正确

### 健康检查命令

```bash
# 集群健康状态
consul members -detailed

# Leader 选举状态
consul operator raft list-peers

# 服务发现测试
dig @localhost -p 8600 consul.service.consul

# ACL 状态
consul acl token list

# API健康检查
curl -s http://localhost:8500/v1/status/leader
curl -s http://localhost:8500/v1/health/state/any
```

### 快速诊断脚本

```bash
# 一键健康检查
cat << 'EOF' > consul-health-check.sh
#!/bin/bash
echo "=== Consul 健康检查 ==="
echo "1. 服务状态:"
sudo systemctl status consul.service --no-pager

echo -e "\n2. 集群成员:"
consul members

echo -e "\n3. Leader状态:"
consul operator raft list-peers

echo -e "\n4. 配置文件检查:"
if [ -f /etc/consul.d/server.json ]; then
    echo "bind_addr: $(cat /etc/consul.d/server.json | jq -r '.bind_addr')"
    echo "encrypt key存在: $([ "$(cat /etc/consul.d/server.json | jq -r '.encrypt')" != "" ] && echo "是" || echo "否")"
fi

echo -e "\n5. 网络检查:"
echo "私有IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
echo "网卡信息: $(ip route | grep default | awk '{print $5}')"
EOF

chmod +x consul-health-check.sh
./consul-health-check.sh
```

## 🔐 安全建议

### 生产环境

1. **网络隔离**
   - 使用私有子网部署 Consul
   - 通过 NAT Gateway 访问互联网
   - 限制安全组规则范围

2. **访问控制**
   - 启用 TLS 加密
   - 定期轮换 Gossip Key
   - 使用 IAM 角色而非硬编码密钥

3. **监控告警**
   - 配置 CloudWatch 监控
   - 设置集群健康告警
   - 启用访问日志记录

### 示例生产配置

```hcl
# prod.tfvars
prefix = "prod-consul"
region = "us-west-2"
aws_account_id = "987654321098"

# 使用更大实例
server_instance_type = "t3.large"
client_instance_type = "t3.medium"

# 增加节点数
server_count = 5
client_count = 3
```

## 📚 相关文档

- [Consul 官方文档](https://www.consul.io/docs)
- [AWS EC2 用户指南](https://docs.aws.amazon.com/ec2/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Consul Cloud Auto-Join](https://www.consul.io/docs/install/cloud-auto-join)
