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
resource "aws_iam_role" "sam_ec2_role_2" {
  name = "sam_ec2_role_2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sam_ec2_policy_attachment" {
  role       = aws_iam_role.sam_ec2_role_2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess" # ✅ works, but broad
}

resource "aws_iam_instance_profile" "sam_ec2_instance_profile_1" {
  name = "sam_ec2_instance_profile_1"
  role = aws_iam_role.sam_ec2_role_2.name
}

# S3 bucket for state
resource "aws_s3_bucket" "tf_state" {
  bucket = "tf_state_backup"
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_encryption" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Backend config (must be in root module, not inside a resource)
terraform {
  backend "s3" {
    bucket         = "tf_state_backup"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}

