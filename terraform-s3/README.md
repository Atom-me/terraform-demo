# Terraform S3 自动化部署示例

## 项目简介
本项目演示如何通过 Terraform 自动化上传本地脚本到 AWS S3，并通过 Makefile 实现多账号、多区域、参数自动化管理。

---

## 目录结构
```
.
├── main.tf           # Terraform 主配置文件
├── variables.tf      # 变量定义
├── scripts/          # 需要上传的脚本目录
│   ├── run-nomad.sh
│   ├── run-api-nomad.sh
│   ├── run-build-cluster-nomad.sh
│   └── run-consul.sh
├── Makefile          # 自动化命令入口
├── setup.config      # 可选，参数默认配置
└── README.md         # 项目说明
```

---

## 环境准备
1. 已安装 [Terraform](https://www.terraform.io/downloads.html)
2. 已安装 [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
3. 配置好 `~/.aws/credentials` 和 `~/.aws/config`，支持多账号
4. 推荐安装 jq（如需高级自动化）

---

## 参数配置（setup.config）
可选，建议团队统一配置常用账号和区域：
```ini
profile=atom
region=us-east-1
```
如未配置，需在命令行传参。

---

## 常用命令
| 命令                        | 说明                       |
|-----------------------------|----------------------------|
| make init                   | 初始化 Terraform           |
| make validate               | 校验配置合法性             |
| make plan                   | 预览变更计划               |
| make apply                  | 应用变更（创建/更新资源）  |
| make destroy                | 销毁所有资源               |
| make output                 | 查看输出                   |
| make clean                  | 清理本地缓存               |
| make help                   | 查看详细帮助说明           |

---

## 参数优先级
1. **命令行传参**（最高优先级）
2. **setup.config**（中等优先级）
3. **Makefile 默认值**（最低优先级）

---

## Makefile 用法示例
- 使用默认参数（setup.config）：
  ```bash
  make plan
  make apply
  ```
- 临时切换账号/区域：
  ```bash
  make plan profile=profile1 region=us-east-1
  make apply profile=profile2 region=ap-southeast-3
  ```

---

## 注意事项
- **profile/region 必填**，未传会报错
- 建议不要将敏感信息（如密钥）提交到代码仓库
- 资源操作前请确认 AWS 账号和区域，避免误操作生产环境
- 如需团队协作，建议统一 setup.config 配置

---

如有更多自动化、参数扩展、CI/CD 集成等需求，欢迎随时交流！ 