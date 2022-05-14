package terraform.security.encryption

test_tf_encryption_at_rest {
    not deny with input as data.resource_changes
}
