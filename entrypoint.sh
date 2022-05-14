#!/bin/sh

set -e
set -o pipefail

echo "Running OPA Policies on Terraform Code"
echo "Terraform Code Location => $INPUT_TERRAFORM_CODE_BASE_PATH"

# Terraform Version
terraform --version

# Find .tf files under this path
pushd $INPUT_TERRAFORM_CODE_BASE_PATH
terraform plan -out plan.out 
terraform show -json plan.out > policies/Infrastructure/tfplan.json
make opa
popd


# Print the Result