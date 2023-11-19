# Create a vpc 
resource "aws_vpc" "vpc" {
  cidr_block            = var.vpc_cidr
  instance_tenancy      = "default"
  enable_dns_hostnames  = true
  tags                  = {
    name = "${var.project_name}-vpc"
  }
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}

# create public subnet on az1
resource "aws_subnet" "public_subnet_az1" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = var.public_subnet_az1_cidr
  availability_zone         = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch   = true
  
  tags                      = {
    name = "public_subnet_az1"
  }
}

# create public subnet on az2
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                    = aws_vpc.vpc.id
  cidr_block                = var.public_subnet_az2_cidr
  availability_zone         = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch   = true
  
  tags                      = {
    name = "public_subnet_az2"
  }
}


# Create an internet gateway and attach to vpc for public access to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    name = "${var.project_name}-IGW"
  }
}


# Create a custom route table
resource "aws_route_table" "route_table" {
  vpc_id    = aws_vpc.vpc.id

  tags      = {
    name = "my_route_table"
  }
}


# create route
resource "aws_route" "route" {
  destination_cidr_block        = "0.0.0.0/0"
  gateway_id                    = aws_internet_gateway.igw.id
  route_table_id                = aws_route_table.route_table.id
}


# associate subnet to route table
resource "aws_route_table_association" "subnet_az1_association" {
  subnet_id         = aws_subnet.public_subnet_az1.id
  route_table_id    = aws_route_table.route_table.id
}


resource "aws_route_table_association" "subnet_az2_association" {
  subnet_id         = aws_subnet.public_subnet_az2.id
  route_table_id    = aws_route_table.route_table.id
}


# create private app subnet on az1
resource "aws_subnet" "private_app_subnet_az1" {
  vpc_id                      = aws_vpc.vpc.id
  cidr_block                  = var.private_app_subnet_az1_cidr
  availability_zone           = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch     = false
  
  tags                        = {
    name = "private_app_subnet_az1"
  }
}


# create private app subnet on az2
resource "aws_subnet" "private_app_subnet_az2" {
  vpc_id                      = aws_vpc.vpc.id
  cidr_block                  = var.private_app_subnet_az2_cidr
  availability_zone           = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch     = false
  
  tags                        = {
    name = "private_app_subnet_az2"
  }
}


# create private DB subnet on az1
resource "aws_subnet" "private_db_subnet_az1" {
  vpc_id                      = aws_vpc.vpc.id
  cidr_block                  = var.private_db_subnet_az1_cidr
  availability_zone           = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch     = false
  
  tags                        = {
    name = "private_db_subnet_az1"
  }
}


# create private DB subnet on az2
resource "aws_subnet" "private_db_subnet_az2" {
  vpc_id                      = aws_vpc.vpc.id
  cidr_block                  = var.private_db_subnet_az2_cidr
  availability_zone           = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch     = false
  
  tags                        = {
    name = "private_db_subnet_az2"
  }
}


# create eip and nat gateway
resource "aws_eip" "natgateway_eip" {
  domain  = "vpc"

  tags    = {
    name = "eip_1"
  }
}


resource "aws_nat_gateway" "natgate_way" {
  allocation_id     = aws_eip.natgateway_eip.id
  subnet_id         = aws_subnet.public_subnet_az1.id

  tags              = {
    name = "natgate_way"
  }
}


# Create a custom route table for nat gateway
resource "aws_route_table" "nat_gateway_route_table" {
  vpc_id     = aws_vpc.vpc.id

  tags       = {
    name = "nat_gateway_route_table"
  }
}


# create route for the nat gateway
resource "aws_route" "natgateway_route" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.natgate_way.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}


# route table association app tier through the nat gatewat
resource "aws_route_table_association" "nat_route_1" {
  subnet_id      = aws_subnet.private_app_subnet_az1.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}


resource "aws_route_table_association" "nat_route_2" {
  subnet_id      = aws_subnet.private_app_subnet_az2.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}


# route table association db tier through the natgate way
resource "aws_route_table_association" "nat_route_db_1" {
  subnet_id      = aws_subnet.private_db_subnet_az1.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}


resource "aws_route_table_association" "nat_route_db_2" {
  subnet_id      = aws_subnet.private_db_subnet_az2.id
  route_table_id = aws_route_table.nat_gateway_route_table.id
}

