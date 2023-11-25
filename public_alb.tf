# Create a security group for the web server load balancer:
resource "aws_security_group" "public_load_balancer_sg" {
  name        = "public-load-balancer-sg"
  description = "security group for the external load_balancer"
  vpc_id      = aws_vpc.vpc.id
  ingress {
      description      = "http traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Outbound traffic rule"
    }
  tags = {
    name = "alb-sg"
  }
}


# Create a load balancer for the web server:
resource "aws_lb" "web_server_load_balancer" {
  name               = "web-server-load-balancer" #load balancer name
  load_balancer_type = "application"
  subnets = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
  internal           = false
  # security group
  security_groups = [aws_security_group.public_load_balancer_sg.id]

  tags = {
    name = "web-server-load-balancer"
  }
}

# Configure the load balancer:
resource "aws_lb_target_group" "web_server_target_group" {
  name        = "webserver-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = "${aws_lb.web_server_load_balancer.arn}" #  load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web_server_target_group.arn}" # target group
  }
}
