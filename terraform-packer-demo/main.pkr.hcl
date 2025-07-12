# AWS Region Configuration
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region where the AMI will be built and resources will be created"
  
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}$", var.aws_region))
    error_message = "AWS region must be in the format: us-east-1, eu-west-1, etc."
  }
}

# Source AMI Configuration
variable "source_ami" {
  type        = string
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
  description = "Name pattern for the source Ubuntu AMI to use as base image"
}

# Output AMI Configuration
variable "ami_name" {
  type        = string
  default     = "e2b-ubuntu-ami-{{isotime \"2006.01.02_15.04.05\" \"Asia/Shanghai\"}}"
  description = "Name for the resulting AMI. Timestamp will be automatically appended to avoid conflicts"
}

# Instance Configuration
variable "instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type to use for building the AMI"
  
  validation {
    condition = contains([
      "t2.micro", "t2.small", "t2.medium", "t2.large",
      "t3.micro", "t3.small", "t3.medium", "t3.large"
    ], var.instance_type)
    error_message = "Instance type must be a valid t2 or t3 instance type."
  }
}

# Volume Configuration
variable "volume_size" {
  type        = number
  default     = 10
  description = "Size of the root volume in GB for the AMI"
  
  validation {
    condition     = var.volume_size >= 8 && var.volume_size <= 100
    error_message = "Volume size must be between 8 and 100 GB."
  }
}

variable "volume_type" {
  type        = string
  default     = "gp3"
  description = "EBS volume type for the root device (gp2, gp3, io1, io2)"
  
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.volume_type)
    error_message = "Volume type must be one of: gp2, gp3, io1, io2."
  }
}

# Tagging Configuration
variable "default_tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "E2B"
    Owner       = "DevOps"
    CreatedBy   = "Packer"
    ManagedBy   = "Packer"
    Repository  = "terraform-packer-demo"
  }
  description = "Default tags to apply to all resources created by Packer"
}

# SSH Configuration
variable "ssh_username" {
  type        = string
  default     = "ubuntu"
  description = "SSH username for connecting to the instance during provisioning"
}

# Provisioning Configuration
variable "pause_before_provisioning" {
  type        = string
  default     = "10s"
  description = "Time to pause before starting provisioning to ensure instance is ready"
}

# Environment Configuration
variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name (dev, staging, prod) - used for tagging and naming"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

packer {
  required_version = ">= 1.10.0"
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = var.ami_name
  instance_type = var.instance_type
  region        = var.aws_region
  
  source_ami_filter {
    filters = {
      name                = var.source_ami
      virtualization-type = "hvm"
      architecture        = "x86_64"
      root-device-type    = "ebs"
      state              = "available"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  
  ssh_username = var.ssh_username
  
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size
    volume_type           = var.volume_type
    delete_on_termination = true
  }
  
  # Apply tags directly from the variable
  tags = merge(var.default_tags, {
    Name        = var.ami_name
    Environment = var.environment
    BuildDate   = "{{isotime \"2006.01.02_15.04.05\" \"Asia/Shanghai\"}}"
  })
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    scripts         = ["scripts/install_software.sh"]
    execute_command = "{{ .Vars }} sudo -E sh '{{ .Path }}'"
    pause_before    = var.pause_before_provisioning
  }
  
  # Post-processor to output AMI information
  post-processor "manifest" {
    output = "manifest.json"
    strip_path = true
  }
}
