#!/bin/bash

set -e  # Exit on any error
set -u  # Exit on undefined variables

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required files exist
if [[ ! -f "main.pkr.hcl" ]]; then
    print_error "main.pkr.hcl not found!"
    exit 1
fi

if [[ ! -f "scripts/install_software.sh" ]]; then
    print_error "scripts/install_software.sh not found!"
    exit 1
fi

# Clean up any previous manifest
if [[ -f "manifest.json" ]]; then
    print_warning "Removing previous manifest.json"
    rm manifest.json
fi

# Initialize Packer plugins
print_status "Initializing Packer plugins..."
if ! packer init main.pkr.hcl; then
    print_error "Packer init failed!"
    exit 1
fi

# Build AMI with Packer
print_status "Starting Packer build..."
if ! packer build main.pkr.hcl; then
    print_error "Packer build failed!"
    exit 1
fi

# Check if manifest was created
if [[ ! -f "manifest.json" ]]; then
    print_error "manifest.json not found after build!"
    exit 1
fi

# Extract AMI ID from manifest.json
print_status "Extracting AMI ID from manifest..."

# Try using jq if available, otherwise use grep/sed
if command -v jq >/dev/null 2>&1; then
    AMI_ID=$(jq -r '.builds[0].artifact_id' manifest.json | cut -d':' -f2)
else
    print_warning "jq not found, using grep/sed to parse manifest.json"
    AMI_ID=$(grep -o '"artifact_id":"[^"]*"' manifest.json | head -1 | sed 's/.*"artifact_id":"[^:]*:\([^"]*\)".*/\1/')
fi

if [[ -z "$AMI_ID" || "$AMI_ID" == "null" ]]; then
    print_error "Failed to extract AMI ID from manifest.json"
    print_error "Please check manifest.json content:"
    cat manifest.json
    exit 1
fi

print_status "AMI created successfully: $AMI_ID"

# Create/update Terraform variable file
print_status "Creating Terraform variable file..."
cat > amivar.tf << EOF
variable "AMI_ID" {
  description = "AMI ID created by Packer"
  type        = string
  default     = "$AMI_ID"
}
EOF

print_status "AMI variable file created: amivar.tf"

# Initialize Terraform if needed
if [[ ! -d ".terraform" ]]; then
    print_status "Initializing Terraform..."
    terraform init
else
    print_status "Terraform already initialized"
fi

# Plan Terraform deployment
print_status "Planning Terraform deployment..."
terraform plan -out=tfplan

# Ask for confirmation before applying
echo
print_warning "Ready to deploy infrastructure with AMI: $AMI_ID"
read -p "Do you want to proceed with terraform apply? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Applying Terraform configuration..."
    terraform apply tfplan
    
    # Clean up plan file
    rm tfplan
    
    print_status "Deployment completed successfully!"
    
    # Show useful outputs
    if terraform output > /dev/null 2>&1; then
        echo
        print_status "Terraform outputs:"
        terraform output
    fi
else
    print_warning "Terraform apply cancelled by user"
    rm tfplan
    exit 0
fi

print_status "Build and launch completed!"
