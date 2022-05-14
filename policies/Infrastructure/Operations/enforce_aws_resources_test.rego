package terraform.operations.resources

test_tf_allowed_resources {
    not deny with input as data.resource_changes
}
