# 可选加载外部配置
-include setup.config

profile ?= default
region  ?= cn-north-1

.PHONY: init validate plan apply destroy output clean required help

required:
	@[ "${profile}" ] || ( echo "profile is required."; exit 1 )
	@[ "${region}" ]  || ( echo "region is required."; exit 1 )

init:
	terraform init -input=false

validate:
	terraform validate

plan: required
	AWS_PROFILE=$(profile) terraform plan -var="aws_profile=$(profile)" -var="aws_region=$(region)"

apply: required
	AWS_PROFILE=$(profile) terraform apply -var="aws_profile=$(profile)" -var="aws_region=$(region)"

destroy: required
	AWS_PROFILE=$(profile) terraform destroy -var="aws_profile=$(profile)" -var="aws_region=$(region)"

output:
	terraform output

clean:
	rm -rf .terraform .terraform.lock.hcl tfplan

help:
	@echo "================ Makefile 帮助 ================"
	@echo "1. 自动加载 setup.config（如有）作为默认参数"
	@echo "2. 支持命令行参数覆盖 setup.config 配置"
	@echo "3. profile/region 必填，未传会报错"
	@echo ""
	@echo "【常用命令】"
	@echo "  make init                # 初始化 Terraform"
	@echo "  make validate            # 校验 Terraform 配置"
	@echo "  make plan                # 预览变更计划（用默认 profile/region）"
	@echo "  make apply               # 应用变更（用默认 profile/region）"
	@echo "  make destroy             # 销毁资源（用默认 profile/region）"
	@echo "  make output              # 查看输出"
	@echo "  make clean               # 清理本地缓存"
	@echo ""
	@echo "【参数覆盖】"
	@echo "  make plan profile=profile1 region=us-east-1"
	@echo "  make apply profile=profile2 region=ap-southeast-3"
	@echo ""
	@echo "【setup.config 示例】"
	@echo "  profile=atom"
	@echo "  region=ap-southeast-3"
	@echo ""
	@echo "【参数优先级】"
	@echo "  1. 命令行传参 > 2. setup.config > 3. Makefile 默认值"
	@echo "===============================================" 