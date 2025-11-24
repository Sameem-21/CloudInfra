resource "aws_security_group" "test_app_sg" {
  name        = "test_app_sg"
  description = "Security group for test application"
  vpc_id      = aws_vpc.test_app.id
  tags = {
    name = "test_app_sg"
  }
}
resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_app_sg.id
}

resource "aws_security_group_rule" "allow_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.test_app_sg.id
}

resource "aws_security_group_rule" "allow_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.test_app_sg.id
}

resource "aws_security_group_rule" "allow_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_app_sg.id
}


resource "aws_security_group" "test_db_sg" {
  name        = "test_db_sg"
  description = "Security group for test database"
  vpc_id      = aws_vpc.test_app.id

  tags = {
    name = "test_db_sg"
  }
}

resource "aws_security_group_rule" "allow_sql_from_app" {
  type                     = "ingress"
  from_port                = 1433
  to_port                  = 1433
  protocol                 = "tcp"
  security_group_id        = aws_security_group.test_db_sg.id
  source_security_group_id = aws_security_group.test_app_sg.id
}


resource "aws_security_group_rule" "allow_db_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1" # all protocols
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.test_db_sg.id
}

#outputs

output "app_security_group_id" {
  value = aws_security_group.test_app_sg.id
}

output "db_security_group_id" {
  value = aws_security_group.test_db_sg.id
}
