#!/bin/bash
set -eux
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "[user-data] Starting Consul Server setup..."

# 环境变量（由 Terraform 模板渲染）
export AWS_REGION="${aws_region}"
export SSH_PUBLIC_KEY="$(echo '${ssh_public_key}' | tr -d '\n')"
export GOSSIP_KEY_SECRET_NAME="${gossip_encryption_key}"

# 获取 Gossip 加密密钥
export CONSUL_GOSSIP_ENCRYPTION_KEY=$(aws secretsmanager get-secret-value \
  --secret-id "$GOSSIP_KEY_SECRET_NAME" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text 2>/dev/null || echo "")

echo "[user-data] Gossip key: $CONSUL_GOSSIP_ENCRYPTION_KEY"

# 安装依赖
apt-get update
apt-get install -y curl unzip jq awscli git

# 设置免密登录
mkdir -p /home/ubuntu/.ssh
if ! grep -q "$SSH_PUBLIC_KEY" /home/ubuntu/.ssh/authorized_keys 2>/dev/null; then
  echo "$SSH_PUBLIC_KEY" >> /home/ubuntu/.ssh/authorized_keys
fi
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# 安装 Consul 二进制
CONSUL_VERSION="1.16.1"
cd /tmp
curl -fsSL https://releases.hashicorp.com/consul/1.16.1/consul_1.16.1_linux_amd64.zip -o consul.zip
unzip consul.zip
mv consul /usr/local/bin/
chmod +x /usr/local/bin/consul

# 创建 Consul 用户和目录
useradd --system --home /etc/consul.d --shell /bin/false consul || true
mkdir -p /opt/consul/data /etc/consul.d
chown -R consul:consul /opt/consul /etc/consul.d

# 写入 Consul 配置文件
cat >/etc/consul.d/server.json <<EOF
{
  "datacenter": "$AWS_REGION",
  "data_dir": "/opt/consul/data",
  "log_level": "INFO",
  "server": true,
  "bootstrap_expect": 3,
  "retry_join": [
    "provider=aws region=$AWS_REGION tag_key=consul-cluster tag_value=server-cluster"
  ],
  "bind_addr": "PRIVATE_IP_PLACEHOLDER",
  "client_addr": "0.0.0.0",
  "ui_config": { "enabled": true },
  "encrypt": "$CONSUL_GOSSIP_ENCRYPTION_KEY"
}
EOF
chown consul:consul /etc/consul.d/server.json
chmod 640 /etc/consul.d/server.json

# 动态获取私有IP并替换占位符
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
sed -i "s/PRIVATE_IP_PLACEHOLDER/$PRIVATE_IP/" /etc/consul.d/server.json

# 写入 systemd 服务单元
cat >/etc/systemd/system/consul.service <<EOF
[Unit]
Description=HashiCorp Consul
Requires=network-online.target
After=network-online.target

[Service]
Type=notify
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# 启动 Consul 服务
systemctl daemon-reload
systemctl enable consul.service
systemctl start consul.service

sleep 3
systemctl status consul.service || true

ls -l /etc/consul.d/
cat /etc/consul.d/server.json

echo "[user-data] Consul Server setup completed successfully." 