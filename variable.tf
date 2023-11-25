variable "region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "my_project"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_az1_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet_az2_cidr" {
  default = "10.0.2.0/24"
}

variable "private_app_subnet_az1_cidr" {
  default = "10.0.3.0/24"
}

variable "private_app_subnet_az2_cidr" {
  default = "10.0.4.0/24"
}

variable "private_db_subnet_az1_cidr" {
  default = "10.0.5.0/24"
}

variable "private_db_subnet_az2_cidr" {
  default = "10.0.6.0/24"
}

variable "rds_engine_version" {
  default = "5.7"
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "rds_password" {
  type     = string
  sensitive = true
}