variable "prefix" { type = string }
variable "region" { type = string }
variable "aws_profile" {
  type        = string
  description = "AWS Profile to use for authentication"
  default     = "default"
}
variable "key_name" { type = string }
variable "ssh_private_key" { type = string }
variable "ssh_public_key" {
  type        = string
  description = "SSH public key path for passwordless login"
  default     = "~/.ssh/id_rsa.pub"
} 