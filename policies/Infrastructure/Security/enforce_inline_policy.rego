package terraform.security.iam
import future.keywords.in
import data.utils as utils

# Allowed Terraform resources
eval_resources = [
  "aws_iam_role",
]

resources_allowed := [ resource | 
    resource = input[_]; 
    resource.type in eval_resources
]

deny {
    resource := resources_allowed[_]
    
    utils.has_key(resource.change.after, "inline_policy")
    inline_policy := resource.change.after.inline_policy[_]
    inline_policy.policy != ""
    print("Not Allowed to create inline_policy on ", "----",resource.type,"---","resources => ", resource.address)
}
