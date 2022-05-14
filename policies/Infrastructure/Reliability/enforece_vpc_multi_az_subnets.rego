package terraform.reliability.multiaz_subnets
import future.keywords.in
import data.utils as utils

subnets[r] {
    r := input[_]
    r.type == "aws_subnet"    
}

vpc [r] {
    r := input[_]
    r.type == "aws_vpc"
}


deny {
    # Get all VPC module names
    vpc_modules := [ r.module_address | r = vpc[_]]

    # Get All Availability Zones created for VPC modules
    subnet_names := [ r.name | r = subnets[_] ; r.module_address in vpc_modules]
    print(subnet_names)

    # Get Unique Subnets Name
    subnets_unique_names := {r | r = subnet_names[_]}
    print(subnets_unique_names)

    # Check the count of each subnet in subnet_names
    some subnet in subnets_unique_names
    subnet_indexes := {i | subnet_names[i] == subnet}

    # Deny if Number of occurences is less than or equal to 1
    count(subnet_indexes) <= 1
    print("Subnets", subnet, "must span across multiple availability zones" ) 
}
