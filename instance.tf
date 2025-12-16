resource "random_id" "suffix" {
  byte_length = 2
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }



  
}

resource "aws_instance" "test_app_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = "test_apsouth1"
  subnet_id                   = aws_subnet.test_app_subnet.id
  security_groups             = [aws_security_group.test_app_sg.id]
  associate_public_ip_address = true
#   user_data = <<EOF
# #!/bin/bash
# export DEBIAN_FRONTEND=noninteractive

# # Update system
# apt-get update -y
# apt-get upgrade -y

# # Install prerequisites
# apt-get install -y curl gnupg apt-transport-https

# # Add Microsoft repo
# curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# # Install sqlcmd
# apt-get update -y
# ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

# # Add sqlcmd to PATH
# echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/profile
# echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /etc/bashrc
# source /etc/profile
# EOF




  tags = {
    Name = "WebServerInstance_${random_id.suffix.hex}"
  }
  depends_on = [aws_security_group.test_app_sg]

}

resource "aws_instance" "test_db_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = "test_apsouth1"
  subnet_id                   = aws_subnet.test_private_subnet.id
  security_groups             = [aws_security_group.test_db_sg.id]
  associate_public_ip_address = false

  tags = {
    Name = "databaseServerInstance_${random_id.suffix.hex}"
  }
  depends_on = [aws_security_group.test_db_sg]

}
terraform {
  backend "s3" {
    bucket         = "tf-state-backup-ec2"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}

#outputs
output "app_instance_name" {
  value = aws_instance.test_app_instance.tags["Name"]
  
}

output "db_instance_name" {
  value = aws_instance.test_db_instance.tags["Name"]
  
}
output "app_instance_id" {
  value = aws_instance.test_app_instance.id
  
}   
output "db_instance_id" {
  value = aws_instance.test_db_instance.id
  
}
output "app_instance_public_ip" {
  value = aws_instance.test_app_instance.public_ip
  
}
output "app_instance_az" {
  value = aws_instance.test_app_instance.availability_zone
}
output "s3_bucket_name" {
  value = aws_s3_bucket.tf_state.bucket
}