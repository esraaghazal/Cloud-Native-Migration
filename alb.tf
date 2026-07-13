resource "aws_lb" "vprofile_alb" {
  name               = "vprofile-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "vprofile_tg" {
  name     = "vprofile-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vprofile_vpc.id

  health_check {
    enabled             = true
    path                = "/login"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-tg"
  }
}

resource "aws_lb_target_group_attachment" "tomcat1" {
  target_group_arn = aws_lb_target_group.vprofile_tg.arn
  target_id        = aws_instance.tomcat_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "tomcat2" {
  target_group_arn = aws_lb_target_group.vprofile_tg.arn
  target_id        = aws_instance.tomcat_2.id
  port             = 8080
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.vprofile_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vprofile_tg.arn
  }
}


