# Create a security group for the app server:
resource "aws_security_group" "appserver_SG" {
  name        = "app server sec_group"
  description = "enable http/https access on port 80/443 via alb and ssh via ssh sg"
  vpc_id      = aws_vpc.vpc.id
  ingress = [
    {
      description      = "https traffic"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      security_groups = [aws_security_group.private_load_balancer_sg.id] # internal lb sg
    },
    {
      description      = "http traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      security_groups = [aws_security_group.private_load_balancer_sg.id] # internal lb sg
    }
  ]
  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "Allow outbound traffic to the internet via NAT gateway"
    }
  ]
  tags = {
    name = "appserver_sg"
  }
}


# create launch template for app server
resource "aws_launch_template" "app_server_launch_template" {
  name   = "app_server_launch_tem"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
    }
  }

  image_id        = "ami-0fc5d935ebf8bc3bc"
  instance_type   = "t2.micro"
  # key_name        = "your-key-pair-name" # optional
  # iam_instance_profile {}
  security_group_names = [aws_security_group.appserver_SG.id]
  user_data       = file("${path.module}/app_tier_user_data.sh")
}


# create asg using the above launch template
resource "aws_autoscaling_group" "app_server_asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier = [aws_subnet.private_app_subnet_az1.id, aws_subnet.private_app_subnet_az2.id] # Specify your subnet IDs
  load_balancers = [aws_lb.app_server_load_balancer.arn]

  launch_template {
    id      = aws_launch_template.app_server_launch_template.id
    version = "${aws_launch_template.app_server_launch_template.latest_version}"
  }

  tag {
    key                 = "Name"
    value               = "example-instance"
    propagate_at_launch = true
  }
}
