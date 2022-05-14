package terraform.security.iam
import future.keywords.in

test_tf_allow_iam_workspaces {
    not deny with input as data.configuration with data.config as data.workspace_configuration
}
