package terraform.operations.tags
import future.keywords.in
import data.utils as utils

# Static Variables
mandatory_tags := [
    "Environment",
    "Terraform",
    "Name"
]

# Tags Null Set
tags_null = [null, {}]

# Ignore these resources if they don't have mandatory tags or not tags at all
ignore_resources = [
    "module.eks.aws_iam_openid_connect_provider.this[0]", 
    "module.fargate_profile_role[0].aws_iam_instance_profile.profile", 
    "module.worker_role[0].aws_iam_instance_profile.profile",
    "module.asg.aws_launch_template.launch_temp",
    "module.asg.aws_autoscaling_group.asg",
    "module.elasticache.aws_elasticache_subnet_group.default",
    "module.alb.aws_lb_listener.http_listener"
]

remove_ignore_resources_from_list (resources_pre_ignore, ignore_list) = resources_post_ignore {
    resources_post_ignore := [
        resource |
        resource = resources_pre_ignore[_];
        not resource.address in ignore_list
    ]
}

missing_tag_resources(resources, tag) = num_resources_without_mandatory_tag {
    resources_without_mandatory_tag := [ 
        resource.address | 
        resource = resources[_] ; 
        not utils.has_key(resource.change.after.tags, tag)
    ]
    # print("Resources without Mandatory Tag", [tag, resources_without_mandatory_tag])

    num_resources_without_mandatory_tag := count(resources_without_mandatory_tag)
}

# All AWS Resources
all_resources := [resource | resource = input[_]; regex.match("^(.*)aws$", resource.provider_name)]

resources_with_no_tags := [ resource | 
    resource = all_resources[_]; 
    resource.change.after.tags in tags_null
    # resource.change.after.tag in tags_null
]

resources_with_tags := [ 
    resource | resource = all_resources[_]; 
    not resource.change.after.tags in tags_null 
]

deny {
    # print("Checking Tags")
    # print("Total Resources:", count(all_resources))
    # print("Resources Without Tags:", [count(resources_with_no_tags), [resource.address | resource = resources_with_no_tags[_]]])
    # print("Resources With Tags:", count(resources_with_tags))
    # print("Ignore List:", ignore_resources)
    # There should be no Resources without tags
    resources_with_no_tags_post_ignore = remove_ignore_resources_from_list(resources_with_no_tags, ignore_resources)
    # print("Resources with no tags post ignore:" , count(resources_with_no_tags_post_ignore), [resource.address | resource = resources_with_no_tags_post_ignore[_]])
    # For resources, with tags, mandatory ones should be present
    missing_mandatory_tags := [ tag | tag = mandatory_tags[_]; missing_tag_resources(resources_with_tags, tag) > 0 ]

    # Check Total violations
    tag_violations := count(resources_with_no_tags_post_ignore) + count(missing_mandatory_tags)

    # print("Total Tag violations : ", tag_violations)

    # Deny if tag violations are not 0
    tag_violations != 0
}
