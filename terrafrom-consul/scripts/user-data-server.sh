#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Consul Server setup via user-data..."

# 设置环境变量（这些将由 Terraform 模板替换）
export CLUSTER_TAG_NAME="server-cluster"
export CONSUL_TOKEN="${consul_token}"
export CONSUL_GOSSIP_ENCRYPTION_KEY="${gossip_encryption_key}"
export SSH_PUBLIC_KEY="${ssh_public_key}"

# 更新系统
apt-get update
apt-get install -y curl unzip jq awscli git

# 设置免密登录
mkdir -p /home/ubuntu/.ssh
echo "$SSH_PUBLIC_KEY" >> /home/ubuntu/.ssh/authorized_keys
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
sort /home/ubuntu/.ssh/authorized_keys | uniq > /home/ubuntu/.ssh/authorized_keys.tmp
mv /home/ubuntu/.ssh/authorized_keys.tmp /home/ubuntu/.ssh/authorized_keys

# 安装 Consul
CONSUL_VERSION="1.16.1"
cd /tmp
curl -fsSL https://releases.hashicorp.com/consul/$${CONSUL_VERSION}/consul_$${CONSUL_VERSION}_linux_amd64.zip -o consul.zip
unzip consul.zip
mv consul /usr/local/bin/
chmod +x /usr/local/bin/consul

# 创建 Consul 用户和目录
useradd --system --home /etc/consul.d --shell /bin/false consul || true
mkdir -p /opt/consul /etc/consul.d /opt/consul/bin
chown -R consul:consul /opt/consul /etc/consul.d

# 安装 bash-commons
mkdir -p /opt/gruntwork
if [ ! -d /opt/gruntwork/bash-commons ]; then
  git clone --branch v0.1.3 https://github.com/gruntwork-io/bash-commons.git /tmp/bash-commons
  cp -r /tmp/bash-commons/modules/bash-commons/src /opt/gruntwork/bash-commons
  chmod -R +x /opt/gruntwork/bash-commons
  chown -R root:root /opt/gruntwork/bash-commons
  rm -rf /tmp/bash-commons
fi

# 下载并设置 run-consul.sh
curl -fsSL https://raw.githubusercontent.com/hashicorp/terraform-aws-consul/master/modules/run-consul/run-consul -o /opt/consul/bin/run-consul.sh
chmod +x /opt/consul/bin/run-consul.sh

# 设置 ulimit
ulimit -n 65536
export GOMAXPROCS=$(nproc)

# 启动 Consul Server
/opt/consul/bin/run-consul.sh --server \
  --cluster-tag-name "$CLUSTER_TAG_NAME" \
  --consul-token "$CONSUL_TOKEN" \
  --enable-gossip-encryption \
  --gossip-encryption-key "$CONSUL_GOSSIP_ENCRYPTION_KEY"

echo "Consul Server setup completed successfully" 