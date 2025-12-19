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
  bucket = "tf-state-backup-ec2"
  region = "ap-south-1"
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