# Create a security group for the web server:
resource "aws_security_group" "webserver_SG" {
  name        = "web server sec_group"
  description = "enable http/https access on port 80/443 via alb and ssh via ssh sg"
  vpc_id      = aws_vpc.vpc.id
  ingress = [
    {
      description      = "https traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      security_groups  = [aws_security_group.public_load_balancer_sg.id] # lb sg
    },
    {
      description      = "http traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups  = [aws_security_group.public_load_balancer_sg.id] # lb sg
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
    name = "webserver_sg"
  }
}


# create launch template for web server
resource "aws_launch_template" "web_server_launch_template" {
  name   = "web_server_launch_tem"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
    }
  }

  image_id        = "ami-06aa3f7caf3a30282"
  instance_type   = "t2.micro"
  # key_name        = "your-key-pair-name"  # optional
  # iam_instance_profile {}
  security_group_names = [aws_security_group.webserver_SG.id]
  user_data       = file("${path.module}/web_tier_user_data.sh")
}


# create asg using the above launch template
resource "aws_autoscaling_group" "web_server_asg" {
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id] # Specify your subnet IDs
  load_balancers = [aws_lb.web_server_load_balancer.arn]
  # you can add your scaling policy

  launch_template {
    id      = aws_launch_template.web_server_launch_template.id
    version = "${aws_launch_template.web_server_launch_template.latest_version}"
  }

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}
