terraform {
  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.2.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}


# Configure the Kind Provider
provider "kind" {}

#variables,此变量指定kubeconfig的文件输出路径
variable "kind_cluster_config_path" {
  type    = string
  default = "/root/.kube/config"
}

#outputs,此输出会在控制台打印kubeconfig内容
output "kubeconfig" {
  value = kind_cluster.default.kubeconfig
}

# Create a cluster
resource "kind_cluster" "default" {
  name            = "test-cluster-atom"
  wait_for_ready  = true
  node_image      = "kindest/node:v1.27.3"
  kubeconfig_path = pathexpand(var.kind_cluster_config_path)

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"


    node {
      role = "control-plane"

      kubeadm_config_patches = [
        <<-EOF
         kind: InitConfiguration
         imageRepository: registry.aliyuncs.com/google_containers
         networking:
           serviceSubnet: 10.0.0.0/16
           apiServerAddress: "0.0.0.0"
         nodeRegistration:
           kubeletExtraArgs:
             node-labels: "ingress-ready=true"
         ---
         kind: kubeletConfiguration
         cgroupDriver: systemd
         cgroupRoot: /kubelet
         failSwapOn: false
         EOF
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
      #在集群里面默认监听的是6443
      extra_port_mappings {
        container_port = 6443
        host_port      = 6443
      }
    }

    #两个worker节点
    node {
      role = "worker"
    }
    node {
      role = "worker"
    }
  }
}


#安装ingress
resource "null_resource" "wait_for_install_ingress" {
  triggers = {
    key = uuid()
  }
  provisioner "local-exec" {
    command = <<EOF
sleep 5
kind load docker-image k8s.gcr.io/ingress-nginx/controller:v1.2.0 --name test-cluster-atom
kind load docker-image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1 --name test-cluster-atom
kubectl create ns ingress-nginx
kubectl apply -f ingress.yaml -n ingress-nginx
printf "\n Waiting for the nginx ingress controller ...\n"
kubectl wait --namespace ingress-nginx \
--for=condition=ready pod \
--selector=app.kubernetes.io/component=controller \
--timeout=90s
EOF
  }
  #集群部署完成之后再部署ingress
  depends_on = [kind_cluster.default]
}


