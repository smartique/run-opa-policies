package terraform.security.iam
import future.keywords.in

allowed_roles = [
    "arn:aws:iam::695292474035:role/nCodeLibrary"
]

eval_role(expr) = constant_value {
    constant_value := expr.constant_value
} else = reference {
    ref := expr.references[_]
    endswith(ref, "assume_role_arn")
    var_name := replace(ref, "local.config.", "")
    reference := data.config[var_name]
}

deny {

    aws_provider_expression := input.provider_config.aws.expressions

    role_arn := eval_role(aws_provider_expression.assume_role[0].role_arn)

    not role_arn in allowed_roles

}
