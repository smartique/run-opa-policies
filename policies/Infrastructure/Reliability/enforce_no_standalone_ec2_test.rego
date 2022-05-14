package terraform.reliability.standalone_ec2

test_tf_standalone_ec2 {
  not deny with input as data.planned_values.root_module
}
