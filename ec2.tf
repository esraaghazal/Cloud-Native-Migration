resource "aws_instance" "tomcat_1" {
  ami                         = var.ami_id
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.private_app_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.tomcat_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  tags = {
    Name = "${var.project_name}-tomcat-1"
  }
}

resource "aws_instance" "tomcat_2" {
  ami                         = var.ami_id
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.private_app_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.tomcat_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  tags = {
    Name = "${var.project_name}-tomcat-2"
  }
}
