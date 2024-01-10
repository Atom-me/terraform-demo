provider "kubernetes" {
  config_path    = "../config/clustera.config"
  config_context = "kind-test-cluster-atom"
  alias          = "clustera"
  insecure       = true

}

#创建devops namespace
resource "kubernetes_namespace" "devops" {
  provider = kubernetes.clustera
  metadata {
    name = "devops"
  }
}