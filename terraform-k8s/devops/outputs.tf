output "service_name" {
  # value = kubernetes_service_v1.jenkins
  value = kubernetes_service_v1.jenkins.metadata[0].name

}