# Global Tags Configuration
# This file defines common tags used across all resources

locals {
  # Common tags applied to all resources
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
    CreatedBy   = "terraform"
    ManagedBy   = "terraform"
    Repository  = "terraform-packer-demo"
  }
  
  # Resource-specific naming convention
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Individual resource names
  resource_names = {
    vpc               = "${local.name_prefix}-vpc"
    subnet            = "${local.name_prefix}-subnet"
    internet_gateway  = "${local.name_prefix}-igw"
    route_table       = "${local.name_prefix}-rt"
    security_group    = "${local.name_prefix}-sg"
    instance          = "${local.name_prefix}-instance"
    keypair           = "${local.name_prefix}-keypair"
    volume            = "${local.name_prefix}-root-volume"
  }
}

# Note: Variables are defined in vars.tf
# This file only contains the tag logic and resource naming

# Output the tags for reference
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

output "resource_names" {
  description = "Standardized resource names"
  value       = local.resource_names
} 