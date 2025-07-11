# E2B AWS Infrastructure Demo

🚀 一个使用 **Packer + Terraform** 构建自定义 AMI 并在 AWS 上部署基础设施的完整示例项目。

## 📋 项目概述

该项目展示了如何使用现代 DevOps 工具链自动化云基础设施的完整生命周期管理：

- **Packer**: 构建预装软件的自定义 Ubuntu AMI
- **Terraform**: 部署 AWS 云基础设施
- **自动化脚本**: 
  - 🚀 `build-and-launch.sh` - 一键构建和部署流程
  - 🧹 `cleanup.sh` - 完整清理所有资源（包括 AMI）

## 🏗️ 架构概览

```
┌─────────────────────────────────────────────────────────────────────┐
│                              AWS Region (us-east-1)                 │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    VPC (10.0.0.0/16)                       │   │
│  │                                                             │   │
│  │  ┌──────────────────────────────────────────────────────┐  │   │
│  │  │          Public Subnet (10.0.1.0/24)                │  │   │
│  │  │                                                      │  │   │
│  │  │  ┌────────────────────────────────────────────────┐ │  │   │
│  │  │  │            EC2 Instance                       │ │  │   │
│  │  │  │         (Custom AMI)                         │ │  │   │
│  │  │  │                                              │ │  │   │
│  │  │  │  • nginx (Web 服务器)                        │ │  │   │
│  │  │  │  • docker (容器运行时)                       │ │  │   │
│  │  │  │  • vim (编辑器)                              │ │  │   │
│  │  │  │  • lvm2 (逻辑卷管理)                         │ │  │   │
│  │  │  └────────────────────────────────────────────────┘ │  │   │
│  │  └──────────────────────────────────────────────────────┘  │   │
│  │                                                             │   │
│  │  ┌──────────────────────────────────────────────────────┐  │   │
│  │  │                 Security Group                       │  │   │
│  │  │  • SSH (22)    - 0.0.0.0/0                          │  │   │
│  │  │  • HTTP (80)   - 0.0.0.0/0                          │  │   │
│  │  │  • HTTPS (443) - 0.0.0.0/0                          │  │   │
│  │  └──────────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Internet Gateway ←→ Public IP                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## 🛠️ 预装软件

自定义 AMI 包含以下预装软件：

- **nginx**: Web 服务器，自动启动
- **docker.io**: 容器运行时
- **vim**: 文本编辑器
- **lvm2**: 逻辑卷管理工具

## 📦 前置条件

### 必需工具
- [Packer](https://www.packer.io/downloads) >= 1.10.0
- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) 配置完成
- `jq` (可选，用于解析 JSON)

### AWS 配置
```bash
# 配置 AWS 凭证
aws configure

# 或者设置环境变量
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### SSH 密钥
确保 SSH 密钥路径正确（在 `vars.tf` 中配置）：
```hcl
variable "PATH_TO_PRIVATE_KEY" {
  default = "/Users/atom/.ssh/id_rsa"  # 修改为您的私钥路径
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "/Users/atom/.ssh/id_rsa.pub"  # 修改为您的公钥路径
}
```

## 🚀 快速开始

### 1. 一键部署（推荐）
```bash
# 克隆项目
git clone <repository-url>
cd terraform-packer-demo

# 运行自动化脚本
sh build-and-launch.sh
```

该脚本会自动：
1. 🔧 初始化 Packer 插件
2. 🏗️ 构建自定义 AMI
3. 📄 生成 AMI 变量文件
4. 🌍 初始化 Terraform
5. 📋 规划部署
6. 🚀 部署基础设施（需要确认）

#### 清理部署
```bash
# 完整清理所有资源（包括 AMI）
sh cleanup.sh
```

### 2. 分步部署

#### 步骤 1: 构建 AMI
```bash
# 初始化 Packer
packer init main.pkr.hcl

# 构建 AMI
packer build main.pkr.hcl
```

#### 步骤 2: 部署基础设施
```bash
# 初始化 Terraform
terraform init

# 规划部署
terraform plan

# 部署
terraform apply
```

## ⚙️ 配置选项

### Packer 配置 (`main.pkr.hcl`)

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `aws_region` | `us-east-1` | AWS 区域 |
| `instance_type` | `t2.micro` | 构建实例类型 |
| `volume_size` | `10` | 根卷大小 (GB) |
| `volume_type` | `gp3` | EBS 卷类型 |
| `environment` | `dev` | 环境标签 |

### Terraform 配置 (`vars.tf`)

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `AWS_REGION` | `us-east-1` | AWS 区域 |
| `PATH_TO_PRIVATE_KEY` | `/Users/atom/.ssh/id_rsa` | SSH 私钥路径 |
| `PATH_TO_PUBLIC_KEY` | `/Users/atom/.ssh/id_rsa.pub` | SSH 公钥路径 |

## 📤 输出信息

部署完成后，您将获得以下信息：

```bash
# 实例信息
instance_id = "i-1234567890abcdef0"
instance_public_ip = "54.123.45.67"
instance_public_dns = "ec2-54-123-45-67.compute-1.amazonaws.com"

# 网络信息
vpc_id = "vpc-12345678"
subnet_id = "subnet-12345678"
security_group_id = "sg-12345678"

# 连接信息
ssh_command = "ssh -i /Users/atom/.ssh/id_rsa ubuntu@54.123.45.67"
nginx_url = "http://54.123.45.67"

# AMI 信息
ami_id = "ami-0ccf93e5cb43ec362"
```

## 🌐 访问服务

### SSH 连接
```bash
ssh -i /Users/atom/.ssh/id_rsa ubuntu@<PUBLIC_IP>
```

### Web 访问
在浏览器中访问：`http://<PUBLIC_IP>`

nginx 默认页面应该正常显示。

## 📁 项目结构

```
terraform-packer-demo/
├── README.md                    # 项目文档
├── build-and-launch.sh         # 自动化构建脚本 🚀
├── cleanup.sh                  # 完整清理脚本 🧹
│
├── main.pkr.hcl                # Packer 主配置文件
├── scripts/
│   └── install_software.sh     # 软件安装脚本
│
├── provider.tf                 # Terraform Provider 配置
├── versions.tf                 # Terraform 版本约束
├── vars.tf                     # Terraform 变量定义
├── outputs.tf                  # Terraform 输出定义
├── amivar.tf                   # AMI ID 变量（自动生成）
│
├── vpc.tf                      # VPC 和网络配置
├── securitygroup.tf            # 安全组配置
├── keypair.tf                  # SSH 密钥对配置
├── instance.tf                 # EC2 实例配置
│
└── manifest.json               # Packer 构建清单（自动生成）
```

## 🔧 自定义配置

### 修改预装软件
编辑 `scripts/install_software.sh`：
```bash
#!/bin/bash
apt-get update
apt-get install -y nginx docker.io vim lvm2

# 添加您需要的软件
apt-get install -y htop git curl wget
```

### 修改实例配置
编辑 `instance.tf` 中的实例类型：
```hcl
resource "aws_instance" "example" {
  ami           = var.AMI_ID
  instance_type = "t3.small"  # 改为更大的实例类型
  # ...
}
```

### 修改网络配置
编辑 `securitygroup.tf` 添加更多端口：
```hcl
# 添加自定义端口
ingress {
  description = "Custom App"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

## 🔍 故障排除

### 1. Packer 构建失败
```bash
# 检查 AWS 凭证
aws sts get-caller-identity

# 检查 Packer 版本
packer version

# 重新初始化插件
packer init main.pkr.hcl
```

### 2. Terraform 部署失败
```bash
# 检查 Terraform 状态
terraform show

# 重新初始化
terraform init -upgrade

# 检查计划
terraform plan -detailed-exitcode
```

### 3. SSH 连接失败
- 确认安全组允许 SSH (22 端口)
- 检查 SSH 密钥路径是否正确
- 确认实例已启动并运行

### 4. 网页无法访问
- 确认安全组允许 HTTP (80 端口)
- 检查 nginx 服务状态：`sudo systemctl status nginx`
- 确认实例有公网 IP

### 5. 清理问题

#### AMI 清理失败
```bash
# 查看所有 E2B 相关的 AMI
aws ec2 describe-images --owners self --filters "Name=tag:Project,Values=E2B"

# 手动删除特定 AMI
aws ec2 deregister-image --image-id ami-xxxxxxxxx
```

#### 快照清理失败
```bash
# 查看孤立的快照
aws ec2 describe-snapshots --owner-ids self --filters "Name=tag:Project,Values=E2B"

# 手动删除快照
aws ec2 delete-snapshot --snapshot-id snap-xxxxxxxxx
```

#### 网络资源清理失败
```bash
# 如果 VPC 无法删除，检查是否有依赖资源
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=vpc-xxxxxxxxx"
aws ec2 describe-nat-gateways --filter "Name=vpc-id,Values=vpc-xxxxxxxxx"
```

## 🧹 清理资源

⚠️ **重要**: `terraform destroy` 无法清理 Packer 创建的 AMI！我们提供了专门的清理脚本来解决这个问题。

### 一键完整清理（推荐）
```bash
# 运行完整清理脚本
sh cleanup.sh
```

该脚本会自动执行以下操作：
1. 🏗️ 销毁所有 Terraform 管理的资源
2. 🗑️ 注销 Packer 创建的 AMI
3. 💾 删除关联的 EBS 快照
4. 📄 清理生成的文件（amivar.tf, manifest.json 等）
5. ✅ 验证清理是否完整

### 分步清理

#### 1. 销毁 Terraform 资源
```bash
terraform destroy
```

#### 2. 手动清理 AMI（如果不使用清理脚本）
```bash
# 获取 AMI ID
AMI_ID=$(cat amivar.tf | grep default | cut -d'"' -f2)

# 注销 AMI
aws ec2 deregister-image --image-id $AMI_ID

# 删除关联的快照
aws ec2 describe-snapshots --owner-ids self --filters "Name=description,Values=*$AMI_ID*" --query 'Snapshots[*].SnapshotId' --output text | xargs -I {} aws ec2 delete-snapshot --snapshot-id {}
```

#### 3. 清理生成的文件
```bash
rm -f amivar.tf manifest.json terraform.tfstate terraform.tfstate.backup .terraform.lock.hcl
rm -rf .terraform/
```

### 清理验证
清理脚本会自动验证以下资源是否完全清理：
- ✅ EC2 实例
- ✅ VPC 和网络资源
- ✅ 安全组
- ✅ 自定义 AMI

如果发现遗留资源，脚本会提供手动清理的命令。

## 📊 成本估算

该项目在 AWS 上的大致成本（美东一区）：

- **t2.micro 实例**: ~$8.5/月（如果符合免费套餐则免费）
- **EBS gp3 存储 (10GB)**: ~$0.8/月
- **公网 IP**: ~$3.6/月
- **数据传输**: 根据使用量

**总计**: 约 $12.9/月（不含免费套餐优惠）

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License

## 🔗 相关链接

- [Packer 官方文档](https://www.packer.io/docs)
- [Terraform 官方文档](https://www.terraform.io/docs)
- [AWS EC2 文档](https://docs.aws.amazon.com/ec2/)

---

**⚡ 快速开始**: `sh build-and-launch.sh`  
**🧹 完整清理**: `sh cleanup.sh` 