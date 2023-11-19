# Create a security group for the web server load balancer:
resource "aws_security_group" "public_load_balancer_sg" {
  name        = "public_load_balancer_sg"
  description = "security group for the external load_balancer"
  vpc_id      = aws_vpc.vpc.id
  ingress = [
    {
      description      = "https traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      description      = "http traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
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
    name = "alb_sg"
  }
}


# Create a load balancer for the web server:
resource "aws_lb" "web_server_load_balancer" {
  name               = "web_server_load_balancer" #load balancer name
  load_balancer_type = "application"
  subnets = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
  internal           = false
  # security group
  security_groups = [aws_security_group.public_load_balancer_sg.id]

  tags = {
    name = "web_server_load_balancer"
  }
}

# Configure the load balancer:
resource "aws_lb_target_group" "web_server_target_group" {
  name        = "web_server_target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = "${aws_lb.web_server_load_balancer.arn}" #  load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web_server_target_group.arn}" # target group
  }
}
