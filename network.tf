
resource "random_id" "vpc_suffix" {
  byte_length = 4
}
resource "aws_vpc" "test_app" {
  cidr_block = "10.0.0.0/16"
lifecycle {
    create_before_destroy = true
}
  tags = {
    Name = "test_app_vpc_${random_id.vpc_suffix.hex}"
  }
}
#subnets
#public subnet for application
resource "aws_subnet" "test_app_subnet" {
  vpc_id            = aws_vpc.test_app.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name="${aws_vpc.test_app.tags["Name"]}_public_subnet"
  }
}

#private subnet for database
resource "aws_subnet" "test_private_subnet" {
  vpc_id            = aws_vpc.test_app.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name="${aws_vpc.test_app.tags["Name"]}_private_subnet_1b"
  }
}

resource "aws_subnet" "test_private_subnet_2" {
  vpc_id            = aws_vpc.test_app.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "ap-south-1c"

   tags = {
    Name="${aws_vpc.test_app.tags["Name"]}_private_subnet_1c"
  }
}
#subnet group for database (rds)
resource "aws_db_subnet_group" "test_private_subnet_group" {
  name       = "test_app_subnet_group"
  lifecycle {
    create_before_destroy = true
  }
  subnet_ids = [aws_subnet.test_private_subnet.id, aws_subnet.test_private_subnet_2.id]
}

resource "aws_internet_gateway" "test_app_igw" {
  vpc_id = aws_vpc.test_app.id

  tags = {
    Name = "${aws_vpc.test_app.tags["Name"]}_test_app_igw"
  }
}

resource "aws_route_table" "test_app_public_rt" {
  vpc_id = aws_vpc.test_app.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_app_igw.id
  }
  tags = {
    Name = "${aws_vpc.test_app.tags["Name"]}_test_app_public_rt"
  }
}

#route table association
resource "aws_route_table_association" "test_app_public_rta" {
  subnet_id      = aws_subnet.test_app_subnet.id
  route_table_id = aws_route_table.test_app_public_rt.id

  
}

#outputs

output "vpc_id" {
  value = aws_vpc.test_app.id
}
output "public_subnet_id" {
  value = aws_subnet.test_app_subnet.id
}
output "private_subnet_id" {
  value = aws_subnet.test_private_subnet.id
}
output "private_subnet_id_2" {
  value = aws_subnet.test_private_subnet_2.id
}
output "private_subnet_group_id" {
  value = aws_db_subnet_group.test_private_subnet_group.id
}