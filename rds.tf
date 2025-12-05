
resource "aws_db_instance" "test_db_instance" {
     identifier         = "test-app-db-instance"
     allocated_storage  = 20
     engine             = "sqlserver-ex"
     #engine_version     = "15.00.4073.23"
     instance_class     = "db.t3.micro"
     #name               = "testappdb"
     username           = "admin"
     password           = "welcome123"
     #parameter_group_name = "default.mysql8.0"
     skip_final_snapshot = true
     db_subnet_group_name = aws_db_subnet_group.test_private_subnet_group.name
     vpc_security_group_ids = [aws_security_group.test_db_sg.id]
     #ec2_compatible_mode = true
     
 
     tags = {
         Name = "${aws_db_instance.test_db_instance.id}_test_app_db_instance"
     }
 }

 output "db_endpoint" {
     value = aws_db_instance.test_db_instance.endpoint
 }