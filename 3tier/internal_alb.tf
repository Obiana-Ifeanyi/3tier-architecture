# Create a security group for the app server load balancer:
resource "aws_security_group" "private_load_balancer_sg" {
  name        = "private_load_balancer_sg"
  description = "security group for the internal load_balancer"
  vpc_id      = aws_vpc.vpc.id
  ingress = [
    {
      description      = "https traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      security_groups = [aws_security_group.webserver_SG.id] # sg for web tier sg
    },
    {
      description      = "http traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups = [aws_security_group.webserver_SG.id] # sg for web tier sg
    }
  ]
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Outbound traffic rule"
    }
  ]
  tags = {
    name = "internal_alb_sg"
  }
}


# Create a load balancer for the app server:
resource "aws_lb" "app_server_load_balancer" {
  name               = "app_server_load-balancer" #load balancer name
  load_balancer_type = "application"
  subnets = [aws_subnet.private_app_subnet_az1.id, aws_subnet.private_app_subnet_az2.id]
  internal           = true
  # security group
  security_groups = [aws_security_group.private_load_balancer_sg.id]

  tags = {
    name = "app_server_load_balancer"
  }
}

# Configure the load balancer:
resource "aws_lb_target_group" "app_server_target_group" {
  name        = "app_server_target_group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_lb.app_server_load_balancer.arn}" #  load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.app_server_target_group.arn}" # target group
  }
}