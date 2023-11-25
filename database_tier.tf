# Create a security group for the database server:
resource "aws_security_group" "database_sg" {
  name        = "db-sg"
  description = "Security group for the database server"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "Permit incoming traffic to RDS from the app server"
    security_groups = [aws_security_group.appserver_SG.id] # Allow traffic in from our app server sg
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow outbound traffic to the internet via NAT gateway"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    name = "RDS-SG"
  }
}


# create subnet groups for rds instance 
resource "aws_db_subnet_group" "subnet_groups" {
  name        = "myrds-subnet-group"
  description = "Subnet group for my RDS instance"
  subnet_ids  = [aws_subnet.private_db_subnet_az1.id, aws_subnet.private_db_subnet_az2.id] # Specify your subnet IDs

  tags = {
    Name = "db-subnet-group"
    Environment = "Production"
  }
}


# Create an RDS instance with Multi-AZ deployment
resource "aws_db_instance" "database_rds" {
  allocated_storage = 10
  db_name = "myrds"
  engine = "mysql"
  engine_version = var.rds_engine_version
  instance_class = var.rds_instance_type
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  username = "admin"
  password = var.rds_password
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = aws_db_subnet_group.subnet_groups.name
  publicly_accessible  = false
  skip_final_snapshot  = true
  multi_az = true # Enable Multi-AZ deployment
  # availability_zone = data.aws_availability_zones.available_zones.names[0]
}
