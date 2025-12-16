# terraform {
#   backend "s3" {
#     bucket         = "tf_state_backup"   # your S3 bucket name
#     key            = "terraform.tfstate"           # file path inside bucket
#     region         = "ap-south-1"                  # your AWS region
#     encrypt        = true                          # enable encryption
#   }
# }

# resource "aws_s3_bucket_versioning" "tf_state_versioning" {
#   bucket = "tf_state_backup"
#   versioning_configuration {
#     status = "Enabled"
#   }
# }
# resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
#   bucket = "tf_state_backup"

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# IAM role for EC2


# Backend config (must be in root module, not inside a resource)
terraform {
  backend "s3" {
    bucket         = "tf_state_backup"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}

