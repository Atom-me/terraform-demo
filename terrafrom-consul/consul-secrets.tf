resource "aws_secretsmanager_secret" "consul_acl_token" {
  name = "${var.prefix}-consul-acl-token"
}
resource "aws_secretsmanager_secret" "consul_gossip_encryption_key" {
  name = "${var.prefix}-consul-gossip-key"
}
resource "aws_secretsmanager_secret" "consul_dns_request_token" {
  name = "${var.prefix}-consul-dns-request-token"
} 