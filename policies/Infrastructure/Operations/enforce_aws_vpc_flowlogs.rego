package terraform.operations.vpc

# Declare resource types to count
resource_types = {"aws_vpc", "aws_flow_log"}

# Merge all resources
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
        #print(name)
        name.type == resource_type
    ]
}

## Check that flow_logs are attached to a vpc and not to eni/subnet
analyze_flow_log := [ valid_vpc_logs |
    some i
    valid_vpc_logs := resource_names["aws_flow_log"]
    valid_vpc_logs[i].values.eni_id == null ; valid_vpc_logs[i].values.subnet_id == null
]

# Rule
deny {
  match_vpc := resource_names["aws_vpc"]
  match_flow_logs = analyze_flow_log
  print("VPC resources declared: ", count(match_vpc))
  print("Flow logs attached to a VPC: ", count(match_flow_logs))
  count(match_vpc) == count(match_flow_logs)
}