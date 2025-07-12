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

# # AMI Configuration
# variable "AMI_ID" {
#   description = "AMI ID created by Packer (will be overridden by amivar.tf)"
#   type        = string
#   default     = ""  # Will be set by build-and-launch.sh
# }

# SSH Key Configuration
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

# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "E2B"
  
  validation {
    condition     = can(regex("^[A-Z][A-Za-z0-9-]*$", var.project_name))
    error_message = "Project name must start with uppercase letter and contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "DevOps"
}

