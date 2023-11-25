# Create a security group for the web server:
resource "aws_security_group" "webserver_SG" {
  name        = "web-server-sec-group"
  description = "enable http/https access on port 80/443 via alb and ssh via ssh sg"
  vpc_id      = aws_vpc.vpc.id
  ingress {
      description      = "http traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups  = [aws_security_group.public_load_balancer_sg.id] # lb sg
    }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Outbound traffic rule"
    }

  tags = {
    name = "webserver-sg"
  }
}


# create launch template for web server
resource "aws_launch_template" "web_server_launch_template" {
  name   = "web-server-launch-tem"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
    }
  }

  image_id        = "ami-06aa3f7caf3a30282"
  instance_type   = "t2.micro"

  # security_group_names = [aws_security_group.webserver_SG.id]
  network_interfaces {
    security_groups = [aws_security_group.webserver_SG.id]
    subnet_id       = aws_subnet.public_subnet_az1.id
    device_index    = 0
  }

  network_interfaces {
    security_groups = [aws_security_group.webserver_SG.id]
    subnet_id       = aws_subnet.public_subnet_az2.id
    device_index    = 1
  }
  user_data = filebase64("${path.module}/web_tier_user_data.sh")
}


# create asg using the above launch template
resource "aws_autoscaling_group" "web_server_asg" {
  health_check_grace_period = 300
  health_check_type         = "EC2"
  # availability_zones = [data.aws_availability_zones.available_zones.names[0], data.aws_availability_zones.available_zones.names[1]]
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id] # Specify your subnet IDs
  # load_balancers = [aws_lb.web_server_load_balancer.arn]
  # you can add your scaling policy
  target_group_arns = [aws_lb_target_group.web_server_target_group.arn]

  launch_template {
    id      = aws_launch_template.web_server_launch_template.id
    version = "${aws_launch_template.web_server_launch_template.latest_version}"
  }

  tag {
    key                 = "Name"
    value               = "web-server"
    propagate_at_launch = true
  }
}
