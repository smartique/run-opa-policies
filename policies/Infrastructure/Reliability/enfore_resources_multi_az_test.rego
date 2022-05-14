package terraform.reliability.multiaz

test_tf_multi_az_resources {
    not deny with input as data.resource_changes with data.tfconfig as data.configuration with data.workspace_config as data.workspace_configuration
}
