package terraform.resources

import future.keywords.in

# Allowed Terraform resources
eval_resources = ["aws_dynamodb_table"]

resources_allowed := [resource |
	resource = input[_]
	resource.type in eval_resources
]

deny {
	resource := resources_allowed[_]

	resource.change.after.point_in_time_recovery[_].enabled != true

	print("Dynamodb tables must be created with point_in_time_recovery enabled", "----", resource.type, "---", "resources => ", resource.address)
}

deny {
	resource := resources_allowed[_]

	not resource.change.after.point_in_time_recovery

	print("Dynamodb tables must be created with point_in_time_recovery enabled", "----", resource.type, "---", "resources => ", resource.address)
}
