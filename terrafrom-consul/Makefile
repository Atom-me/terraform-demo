# Consul 高可用集群 Makefile
.PHONY: help init plan apply destroy validate fmt clean status ssh-server ssh-client

# 默认目标
.DEFAULT_GOAL := help

# 从 setup.config 读取配置（如果存在）
ifneq (,$(wildcard setup.config))
    include setup.config
    export
endif

# 配置变量 - 优先级：命令行参数 > setup.config > 默认值
PREFIX ?= my-consul
REGION ?= us-east-1
AWS_PROFILE ?= default
KEY_NAME ?= my-key-pair
SSH_PRIVATE_KEY ?= ~/.ssh/id_rsa
SSH_PUBLIC_KEY ?= ~/.ssh/id_rsa.pub

# 如果 setup.config 中有 AWS_REGION，覆盖 REGION
ifdef AWS_REGION
    REGION := $(AWS_REGION)
endif

# Terraform 变量
TF_VARS := -var="prefix=$(PREFIX)" \
           -var="region=$(REGION)" \
           -var="aws_profile=$(AWS_PROFILE)" \
           -var="key_name=$(KEY_NAME)" \
           -var="ssh_private_key=$(SSH_PRIVATE_KEY)" \
           -var="ssh_public_key=$(SSH_PUBLIC_KEY)"

help: ## 显示帮助信息
	@echo "Consul 高可用集群管理命令："
	@echo ""
	@echo "使用示例："
	@echo "  make plan                                    # 使用默认参数或 setup.config"
	@echo "  make apply PREFIX=test REGION=us-west-2      # 指定前缀和区域"
	@echo "  make apply AWS_PROFILE=production            # 指定 AWS profile"
	@echo "  make destroy PREFIX=test AWS_PROFILE=dev     # 销毁指定环境"
	@echo ""
	@echo "配置文件："
	@echo "  cp setup.config.example setup.config        # 创建配置文件"
	@echo "  编辑 setup.config 设置默认参数                # 避免每次输入参数"
	@echo ""
	@echo "当前配置："
	@echo "  PREFIX=$(PREFIX)"
	@echo "  REGION=$(REGION)" 
	@echo "  AWS_PROFILE=$(AWS_PROFILE)"
	@echo "  KEY_NAME=$(KEY_NAME)"
	@echo "  SSH_PRIVATE_KEY=$(SSH_PRIVATE_KEY)"
	@echo "  SSH_PUBLIC_KEY=$(SSH_PUBLIC_KEY)"
	@echo ""
	@echo "可用命令："
	@echo ""
	@echo "  \033[33m基础命令:\033[0m"
	@grep -E '^(setup|init|validate|fmt|plan|apply|destroy):.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[36m%-13s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  \033[33m集群管理:\033[0m"
	@grep -E '^(status|consul-status|ui|ssh-server|ssh-client|test-ssh|logs-server|logs-client):.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[36m%-13s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  \033[33m开发工具:\033[0m"
	@grep -E '^(dev-init|dev-deploy|dev-test|clean|clean-secrets|clean-all):.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[36m%-13s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  \033[33m其他:\033[0m"
	@grep -E '^(help|prod-deploy):.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[36m%-13s\033[0m %s\n", $$1, $$2}'

setup: ## 创建配置文件
	@if [ ! -f setup.config ]; then \
		cp setup.config.example setup.config; \
		echo "✅ 已创建 setup.config，请编辑配置后再运行部署命令"; \
		echo "💡 提示：编辑 setup.config 文件设置您的 AWS_PROFILE 和其他参数"; \
	else \
		echo "⚠️  setup.config 已存在"; \
	fi

init: ## 初始化 Terraform
	terraform init

validate: ## 验证 Terraform 配置
	terraform validate

fmt: ## 格式化 Terraform 代码
	terraform fmt -recursive

plan: ## 生成 Terraform 执行计划
	@echo "正在生成执行计划..."
	@echo "参数: PREFIX=$(PREFIX) REGION=$(REGION) AWS_PROFILE=$(AWS_PROFILE)"
	terraform plan $(TF_VARS)

apply: ## 部署 Consul 集群
	@echo "正在部署 Consul 集群..."
	@echo "参数: PREFIX=$(PREFIX) REGION=$(REGION) AWS_PROFILE=$(AWS_PROFILE)"
	terraform apply $(TF_VARS) -auto-approve

destroy: ## 销毁 Consul 集群
	@echo "正在销毁 Consul 集群..."
	@echo "参数: PREFIX=$(PREFIX) REGION=$(REGION) AWS_PROFILE=$(AWS_PROFILE)"
	terraform destroy $(TF_VARS) -auto-approve
	@echo ""
	@echo "清理 Secrets Manager 资源..."
	@aws --profile $(AWS_PROFILE) --region $(REGION) secretsmanager delete-secret --secret-id $(PREFIX)-consul-acl-token --force-delete-without-recovery 2>/dev/null || echo "Secret $(PREFIX)-consul-acl-token 不存在或已删除"
	@aws --profile $(AWS_PROFILE) --region $(REGION) secretsmanager delete-secret --secret-id $(PREFIX)-consul-gossip-key --force-delete-without-recovery 2>/dev/null || echo "Secret $(PREFIX)-consul-gossip-key 不存在或已删除"
	@aws --profile $(AWS_PROFILE) --region $(REGION) secretsmanager delete-secret --secret-id $(PREFIX)-consul-dns-request-token --force-delete-without-recovery 2>/dev/null || echo "Secret $(PREFIX)-consul-dns-request-token 不存在或已删除"
	@echo "✅ 清理完成"

status: ## 查看集群状态
	@echo "=== Terraform 状态 ==="
	terraform show
	@echo ""
	@echo "=== 实例列表 ==="
	terraform output -json | jq -r '.server_ips.value[] as $$ip | "Server: \($$ip)"'
	terraform output -json | jq -r '.client_ips.value[] as $$ip | "Client: \($$ip)"'

ssh-server: ## SSH 连接到第一个 Server 节点
	@SERVER_IP=$$(terraform output -json | jq -r '.server_ips.value[0]'); \
	echo "连接到 Server: $$SERVER_IP"; \
	ssh -i $(SSH_PRIVATE_KEY) ubuntu@$$SERVER_IP

ssh-client: ## SSH 连接到第一个 Client 节点
	@CLIENT_IP=$$(terraform output -json | jq -r '.client_ips.value[0]'); \
	echo "连接到 Client: $$CLIENT_IP"; \
	ssh -i $(SSH_PRIVATE_KEY) ubuntu@$$CLIENT_IP

consul-status: ## 检查 Consul 集群状态
	@echo "=== Consul 集群成员 ==="
	@SERVER_IP=$$(terraform output -json | jq -r '.server_ips.value[0]'); \
	ssh -i $(SSH_PRIVATE_KEY) ubuntu@$$SERVER_IP "consul members"
	@echo ""
	@echo "=== Consul Leader ==="
	@SERVER_IP=$$(terraform output -json | jq -r '.server_ips.value[0]'); \
	ssh -i $(SSH_PRIVATE_KEY) ubuntu@$$SERVER_IP "consul operator raft list-peers"

ui: ## 打开 Consul UI
	@SERVER_IP=$$(terraform output -json | jq -r '.server_ips.value[0]'); \
	echo "Consul UI: http://$$SERVER_IP:8500"; \
	open "http://$$SERVER_IP:8500" || echo "请手动打开: http://$$SERVER_IP:8500"

clean: ## 清理 Terraform 文件
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f terraform.tfstate*
	rm -f *.tfplan

clean-secrets: ## 强制清理 AWS Secrets Manager 资源
	@echo "强制清理 Secrets Manager 资源..."
	@echo "参数: PREFIX=$(PREFIX) REGION=$(REGION) AWS_PROFILE=$(AWS_PROFILE)"
	@aws --profile $(AWS_PROFILE) --region $(REGION) secretsmanager delete-secret --secret-id $(PREFIX)-consul-acl-token --force-delete-without-recovery 2>/dev/null || echo "Secret $(PREFIX)-consul-acl-token 不存在或已删除"
	@aws --profile $(AWS_PROFILE) --region $(REGION) secretsmanager delete-secret --secret-id $(PREFIX)-consul-gossip-key --force-delete-without-recovery 2>/dev/null || echo "Secret $(PREFIX)-consul-gossip-key 不存在或已删除"
	@aws --profile $(AWS_PROFILE) --region $(REGION) secretsmanager delete-secret --secret-id $(PREFIX)-consul-dns-request-token --force-delete-without-recovery 2>/dev/null || echo "Secret $(PREFIX)-consul-dns-request-token 不存在或已删除"
	@echo "✅ Secrets 清理完成"

clean-all: destroy clean clean-secrets ## 彻底清理所有资源和本地文件
	@echo "🧹 彻底清理完成！"

logs-server: ## 查看第一个 Server 节点的 Consul 日志
	@SERVER_IP=$$(terraform output -json | jq -r '.server_ips.value[0]'); \
	ssh -i $(SSH_PRIVATE_KEY) ubuntu@$$SERVER_IP "sudo journalctl -u consul.service -f"

logs-client: ## 查看第一个 Client 节点的 Consul 日志
	@CLIENT_IP=$$(terraform output -json | jq -r '.client_ips.value[0]'); \
	ssh -i $(SSH_PRIVATE_KEY) ubuntu@$$CLIENT_IP "sudo journalctl -u consul.service -f"

test-ssh: ## 测试所有节点的 SSH 免密登录
	@echo "=== 测试 Server 节点免密登录 ==="
	@terraform output -json | jq -r '.server_ips.value[]' | while read ip; do \
		echo "测试 Server: $$ip"; \
		ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@$$ip "echo '✅ Server $$ip 免密登录成功'" || echo "❌ Server $$ip 免密登录失败"; \
	done
	@echo ""
	@echo "=== 测试 Client 节点免密登录 ==="
	@terraform output -json | jq -r '.client_ips.value[]' | while read ip; do \
		echo "测试 Client: $$ip"; \
		ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no ubuntu@$$ip "echo '✅ Client $$ip 免密登录成功'" || echo "❌ Client $$ip 免密登录失败"; \
	done

# 开发相关命令
dev-init: setup init fmt validate ## 开发环境初始化（包含配置文件创建）

dev-deploy: dev-init plan apply ## 开发环境一键部署

dev-test: consul-status test-ssh ui ## 部署后测试

# 生产相关命令
prod-deploy: ## 生产环境部署（需要手动确认）
	@echo "⚠️  即将部署到生产环境，请确认："
	@echo "当前参数: PREFIX=$(PREFIX) REGION=$(REGION) AWS_PROFILE=$(AWS_PROFILE)"
	@read -p "输入 'yes' 继续: " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		make apply; \
	else \
		echo "已取消部署"; \
	fi 