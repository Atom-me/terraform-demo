#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

print_status "Starting cleanup process..."

# Step 1: Destroy Terraform resources
print_status "Step 1: Destroying Terraform resources..."
if [[ -f "terraform.tfstate" ]] || [[ -d ".terraform" ]]; then
    if terraform show > /dev/null 2>&1; then
        print_warning "Terraform state found. Destroying infrastructure..."
        terraform destroy -auto-approve
        print_status "Terraform resources destroyed successfully"
    else
        print_warning "No active Terraform resources found"
    fi
else
    print_warning "No Terraform state found, skipping Terraform destroy"
fi

# Step 2: Clean up Packer-created AMI
print_status "Step 2: Cleaning up Packer-created AMI..."

# Get AMI ID from amivar.tf if it exists
AMI_ID=""
if [[ -f "amivar.tf" ]]; then
    AMI_ID=$(grep -o 'default[[:space:]]*=[[:space:]]*"ami-[^"]*"' amivar.tf | sed 's/.*"\\(ami-[^"]*\\)".*/\\1/' || true)
fi

# If AMI_ID is still empty, try to get it from manifest.json
if [[ -z "$AMI_ID" ]] && [[ -f "manifest.json" ]]; then
    if command -v jq >/dev/null 2>&1; then
        AMI_ID=$(jq -r '.builds[0].artifact_id' manifest.json 2>/dev/null | cut -d':' -f2 || true)
    else
        AMI_ID=$(grep -o '"artifact_id":"[^"]*"' manifest.json | head -1 | sed 's/.*"artifact_id":"[^:]*:\\([^"]*\\)".*/\\1/' || true)
    fi
fi

if [[ -n "$AMI_ID" && "$AMI_ID" != "null" && "$AMI_ID" != "" ]]; then
    print_info "Found AMI ID: $AMI_ID"
    
    # Check if AMI exists
    if aws ec2 describe-images --image-ids "$AMI_ID" --owners self >/dev/null 2>&1; then
        print_warning "Deregistering AMI: $AMI_ID"
        aws ec2 deregister-image --image-id "$AMI_ID"
        print_status "AMI deregistered successfully"
        
        # Get and delete associated snapshots
        print_status "Finding and deleting associated snapshots..."
        SNAPSHOTS=$(aws ec2 describe-snapshots --owner-ids self --filters "Name=description,Values=*$AMI_ID*" --query 'Snapshots[*].SnapshotId' --output text 2>/dev/null || true)
        
        if [[ -n "$SNAPSHOTS" ]]; then
            for snapshot in $SNAPSHOTS; do
                if [[ "$snapshot" != "None" ]]; then
                    print_info "Deleting snapshot: $snapshot"
                    aws ec2 delete-snapshot --snapshot-id "$snapshot"
                fi
            done
            print_status "Associated snapshots deleted successfully"
        else
            print_warning "No associated snapshots found"
        fi
    else
        print_warning "AMI $AMI_ID not found or already deleted"
    fi
else
    print_warning "No AMI ID found in amivar.tf or manifest.json"
fi

# Step 3: Clean up generated files
print_status "Step 3: Cleaning up generated files..."

FILES_TO_CLEAN=(
    "amivar.tf"
    "manifest.json" 
    "terraform.tfstate"
    "terraform.tfstate.backup"
    "tfplan"
    ".terraform.lock.hcl"
)

for file in "${FILES_TO_CLEAN[@]}"; do
    if [[ -f "$file" ]]; then
        print_info "Removing file: $file"
        rm "$file"
    fi
done

# # Clean up .terraform directory
# if [[ -d ".terraform" ]]; then
#     print_info "Removing .terraform directory"
#     rm -rf ".terraform"
# fi

# Step 4: Verify cleanup
print_status "Step 4: Verifying cleanup..."

# Get project name from Terraform variables
PROJECT_NAME=$(grep -o 'default[[:space:]]*=[[:space:]]*"[^"]*"' tags.tf | grep project_name -A1 | tail -1 | sed 's/.*"\\([^"]*\\)".*/\\1/' 2>/dev/null || echo "E2B")
print_info "Using project name: $PROJECT_NAME"

# Check if any project-related resources still exist
print_info "Checking for remaining $PROJECT_NAME resources..."

# Check for EC2 instances
INSTANCES=$(aws ec2 describe-instances --filters "Name=tag:Project,Values=$PROJECT_NAME" "Name=instance-state-name,Values=running,pending,stopping,stopped" --query 'Reservations[*].Instances[*].InstanceId' --output text 2>/dev/null || true)
if [[ -n "$INSTANCES" && "$INSTANCES" != "None" ]]; then
    print_warning "Found remaining EC2 instances: $INSTANCES"
else
    print_status "✓ No $PROJECT_NAME EC2 instances found"
fi

# Check for VPCs
VPCS=$(aws ec2 describe-vpcs --filters "Name=tag:Project,Values=$PROJECT_NAME" --query 'Vpcs[*].VpcId' --output text 2>/dev/null || true)
if [[ -n "$VPCS" && "$VPCS" != "None" ]]; then
    print_warning "Found remaining VPCs: $VPCS"
else
    print_status "✓ No $PROJECT_NAME VPCs found"
fi

# Check for Security Groups
SGS=$(aws ec2 describe-security-groups --filters "Name=tag:Project,Values=$PROJECT_NAME" --query 'SecurityGroups[*].GroupId' --output text 2>/dev/null || true)
if [[ -n "$SGS" && "$SGS" != "None" ]]; then
    print_warning "Found remaining Security Groups: $SGS"
else
    print_status "✓ No $PROJECT_NAME Security Groups found"
fi

# Check for AMIs
AMIS=$(aws ec2 describe-images --owners self --filters "Name=tag:Project,Values=$PROJECT_NAME" --query 'Images[*].ImageId' --output text 2>/dev/null || true)
if [[ -n "$AMIS" && "$AMIS" != "None" ]]; then
    print_warning "Found remaining AMIs: $AMIS"
    echo "You may want to manually clean these up if they're not needed:"
    for ami in $AMIS; do
        echo "  aws ec2 deregister-image --image-id $ami"
    done
else
    print_status "✓ No $PROJECT_NAME AMIs found"
fi

print_status "Cleanup completed successfully! 🎉"
print_info "Summary of actions taken:"
echo "  • Destroyed Terraform-managed resources"
echo "  • Deregistered Packer-created AMI"
echo "  • Deleted associated EBS snapshots"
echo "  • Cleaned up generated files"
echo ""
print_warning "Note: If you see any remaining resources above, you may need to clean them manually." 