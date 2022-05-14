package terraform.cost.dynamo

resource_types = {"aws_appautoscaling_policy", "aws_appautoscaling_target", "aws_dynamodb_table"}

root_resources := [resource | 
    resource = input.root_module.resources[_]
]

child_resources := [resource | 
    resource = input.root_module.child_modules[_].resources[_] 
]

merged_resources := array.concat(root_resources , child_resources)

# Filters
resource_names[resource_type] = all {
    some resource_type
    resource_types[resource_type]
    all := [name |
        name = merged_resources[_]
        name.type == resource_type
    ]
}

deny {
  # tables
  tables := resource_names["aws_dynamodb_table"]
  print("=======")
  print("DynamoTable resources declared: ", count(tables))

  # targets
  targets := resource_names["aws_appautoscaling_target"]
  read_targets = [t | t := targets[_]; t.values.scalable_dimension == "dynamodb:table:ReadCapacityUnits"]
  write_targets = [t | t := targets[_]; t.values.scalable_dimension == "dynamodb:table:WriteCapacityUnits"]
  print("=======")
  print("Read Targets: ", count(read_targets))
  print("Write Targets: ", count(write_targets))
  print("=======")

  # policies
  policies := resource_names["aws_appautoscaling_policy"]
  read_policies := [p | p := policies[_]; p.values.scalable_dimension == "dynamodb:table:ReadCapacityUnits"]
  write_policies := [p | p := policies[_]; p.values.scalable_dimension == "dynamodb:table:WriteCapacityUnits"]
  print("Read policies: ", count(read_policies))
  print("Write policies: ", count(write_policies))
  print("=======")

  count(tables) == count(read_targets); count(tables) == count(write_targets); count(read_targets) == count(read_policies); count(write_targets) == count(write_policies) 
}