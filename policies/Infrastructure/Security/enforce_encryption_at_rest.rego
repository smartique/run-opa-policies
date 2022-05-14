package terraform.security.encryption
import future.keywords.in

# S3 Bucket Changes
s3_buckets[r] {
    r := input[_]
    r.type == "aws_s3_bucket"
}

# EBS Volumes
ebs_volumes[r] {
    r := input[_]
    r.type == "aws_ebs_volume"
}

launch_template[r] {
    r := input[_]
    r.type == "aws_launch_template"
}

# RDS Instances
rds[r] {
    r := input[_]
    r.type == "aws_db_instance"
}

# Deny unencrypted S3 Buckets
deny {
    r := s3_buckets[_]
    s3_encryption_enabled := count(r.change.after.server_side_encryption_configuration)
    s3_encryption_enabled == 0
    print("Encryption at Rest is not enabled for", r.address)
}

# Deny unencrypted EBS Volumes
deny {
    r := ebs_volumes[_]
    r.change.after.encrypted == false
    print("Encryption at Rest is not enabled for", r.address)
}

# Deny unencrypted EBS Volumes created by Launch Config
deny {
    r := launch_template[_]
    bdm := r.change.after.block_device_mappings[_]
    ebs := bdm.ebs[_]
    ebs.encrypted == "false"
    print("Encryption at Rest is not enabled for", r.address)
}

# Deny unencrypted RDS Instances
deny {
    r := rds[_]
    r.change.after.storage_encrypted == false
    print("Encryption at Rest is not enabled for", r.address)
}
