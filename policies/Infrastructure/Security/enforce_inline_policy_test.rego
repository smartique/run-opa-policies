package terraform.security.iam

test_tf_allowed_policies {
    not deny with input as data.resource_changes
}
