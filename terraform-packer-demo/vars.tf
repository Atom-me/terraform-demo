# AWS Configuration
variable "AWS_REGION" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.AWS_REGION))
    error_message = "AWS region must be in valid format (e.g., us-east-1, eu-west-1)."
  }
}

# AMI Configuration
# variable "AMI_ID" {
#   description = "AMI ID created by Packer (will be overridden by amivar.tf)"
#   type        = string
#   default     = ""  # Will be set by build-and-launch.sh
# }

# # SSH Key Configuration
variable "PATH_TO_PRIVATE_KEY" {
  description = "Path to the private SSH key file"
  type        = string
  default     = "/Users/atom/.ssh/id_rsa"
}

variable "PATH_TO_PUBLIC_KEY" {
  description = "Path to the public SSH key file"
  type        = string
  default     = "/Users/atom/.ssh/id_rsa.pub"
}

