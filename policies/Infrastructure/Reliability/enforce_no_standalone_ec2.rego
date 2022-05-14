package terraform.reliability.standalone_ec2
import future.keywords.in

# All AWS Resources
root_resources := [resource | resource = input.resources[_]; regex.match("^(.*)aws$", resource.provider_name)]
child_resources := [resource | resource = input.child_modules[_].resources[_]; regex.match("^(.*)aws$", resource.provider_name)]  
all_resources := array.concat(root_resources , child_resources)

ec2_instance_resources := [ resource | 
    resource = all_resources[_]; 
    resource.type == "aws_instance"
]

deny {
  # print("EC2 Instances not part of ASG:", count(ec2_instance_resources))
  count(ec2_instance_resources) > 0
}
