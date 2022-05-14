package terraform.operations.resources
import future.keywords.in
import data.utils as utils

# Denied Terraform resources
denied_resources = [
  "aws_iam_user",
  "aws_iam_access_key"
]


deny {
    resource := input[_]

    utils.array_contains( denied_resources, resource.type)
    print("Not Allowed to Create", "----",resource.type,"---","resources => ", resource.address)
}
