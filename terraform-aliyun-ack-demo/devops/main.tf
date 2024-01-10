provider "kubernetes" {
  config_path    = "../config/clustera.config"
  config_context = "kubernetes-admin-cc974da490dc84f738811bc174d67da5c"
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