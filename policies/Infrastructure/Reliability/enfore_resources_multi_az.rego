package terraform.reliability.multiaz
import future.keywords.in
import data.utils as utils

determineSubnetVariableType(var) = variable {
    utils.str_contains(var, "^.*var.*$")
    variable := "variable"
} else = output {
    utils.str_contains(var, "^.*output.*$")
    output := "output"
}

determineSubnets(type, var_name) = variable {
    type == "variable"
    variable := input.variables[var_name].value
} else = variable {
    type == "output"
    variable_full := utils.eval_expression(data.tfconfig.root_module.module_calls.vpc.module.outputs.output.expression, var_name)
    variable_name := utils.last_element(split(variable_full[0], "."))
    variable := data.workspace_config.vpc_settings[variable_name]
}

# Determine Subnets for ALB/ASG
eval_subnets(resource, module_name, resource_type, property, variable_name) = subnets {
    utils.has_key(resource.change.after, property)
    subnets := resource.change.after.subnets
} else =  subnets {
    r := data.tfconfig.root_module.resources[_]
    r.type == resource_type
    subnets := r.expressions.subnet_ids   
} else = subnets {
    utils.has_key(data.tfconfig.root_module.module_calls, module_name)
    utils.has_key(data.tfconfig.root_module.module_calls[module_name].expressions, variable_name)
    references := utils.eval_expression(data.tfconfig.root_module.module_calls[module_name].expressions[variable_name], "subnets")
    subnets := [ determineSubnets(determineSubnetVariableType(r), utils.last_element(split(r, ".")))  | r = references[_]]
}

# RDS Resources
rds[r] {
    r := input[_]
    r.type == "aws_db_instance"
}

# ALB Resources
alb[r] {
    r := input[_]
    r.type == "aws_lb"
}

# ASG Resources
asg[r] {
    r := input[_]
    r.type == "aws_autoscaling_group"
}


# Deny single AZ RDS Instances
deny {
    r := rds[_]
    r.change.after.multi_az == false
    print("Not Allowed to Create", "-",r.type,"-","without Multi-AZ setup => ", r.address)
}

# Deny single AZ ALBs
deny {
    r := alb[_]
    module_name := replace(r.module_address, "module.", "")
    subnets := eval_subnets(r, module_name, r.type, "subnets", "subnet_ids")
    print("Subnets for ALB", subnets)
    utils.is_single(subnets)
    print("Not Allowed to Create", "-",r.type,"-","without Multi-AZ setup => ", r.address)
}

# Deny Single AZ Autoscaling Groups
deny {
    r := asg[_]
    module_name := replace(r.module_address, "module.", "")
    subnets := eval_subnets(r, module_name, r.type, "vpc_zone_identifier", "subnets")
    print("Subnets for ASG", subnets)
    utils.is_single(subnets)
    print("Not Allowed to Create", "-",r.type,"-","without Multi-AZ setup => ", r.address)
}
