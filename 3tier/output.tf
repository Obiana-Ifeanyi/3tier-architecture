# Output VPC ID
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# Output Public Subnet IDs
output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]
}

# Output Private App Subnet IDs
output "private_app_subnet_ids" {
  value = [aws_subnet.private_app_subnet_az1.id, aws_subnet.private_app_subnet_az2.id]
}

# Output Private DB Subnet IDs
output "private_db_subnet_ids" {
  value = [aws_subnet.private_db_subnet_az1.id, aws_subnet.private_db_subnet_az2.id]
}

# Output Internet Gateway ID
output "igw_id" {
  value = aws_internet_gateway.igw.id
}

# Output NAT Gateway ID
output "nat_gateway_id" {
  value = aws_nat_gateway.natgate_way.id
}

# Output RDS Subnet Group ID
output "db_subnet_group_id" {
  value = aws_db_subnet_group.subnet_groups.id
}

# Output Load Balancer ARN
output "web_lb_arn" {
  value = aws_lb.web_server_load_balancer.arn
}

# Output App Server Launch Template ID
output "app_server_launch_template_id" {
  value = aws_launch_template.app_server_launch_template.id
}

# Output Web Server Launch Template ID
output "web_server_launch_template_id" {
  value = aws_launch_template.web_server_launch_template.id
}

# Output Security Group IDs
output "webserver_sg_id" {
  value = aws_security_group.webserver_SG.id
}

output "appserver_sg_id" {
  value = aws_security_group.appserver_SG.id
}

output "internal_alb_sg_id" {
  value = aws_security_group.private_load_balancer_sg.id
}

output "public_alb_sg_id" {
  value = aws_security_group.public_load_balancer_sg.id
}
