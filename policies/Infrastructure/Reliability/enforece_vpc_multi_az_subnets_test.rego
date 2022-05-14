package terraform.reliability.multiaz_subnets

test_tf_multi_az_subnets {
    not deny with input as data.resource_changes
}