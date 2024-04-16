# Cloud Three-Tier Architecture Deployment using Terraform

This repository contains the Terraform code for deploying a three-tier architecture on AWS cloud. The architecture consists of three layers: Presentation layer, Application layer, and Data layer. It leverages various AWS services including ALB (Application Load Balancer), ASG (Auto Scaling Group), VPC (Virtual Private Cloud) and its components, EC2 (Elastic Compute Cloud), CloudWatch for monitoring, and RDS (Relational Database Service).
<br/><br/>

## Architecture Overview

The three-tier architecture is structured as follows:

1. **Presentation Layer**: This layer serves as the entry point for users and includes the Application Load Balancer (ALB) to distribute incoming traffic among multiple instances.

2. **Application Layer**: The application logic resides in this layer, deployed on EC2 instances within Auto Scaling Groups (ASG). ASG ensures high availability and scalability by automatically adjusting the number of instances based on demand.

3. **Data Layer**: This layer manages the storage and retrieval of data. It includes Amazon RDS, a managed relational database service, providing scalable and reliable databases.
   
<br/><br/>
<img src="3_TIER_DIA.png" alt="Architecture Diagram" width="600">
<br/><br/>

## Terraform Modules

The Terraform code is organized into modules for better maintainability and reusability:

1. **VPC Module**: Defines the Virtual Private Cloud (VPC), including subnets, route tables, and internet gateway, providing network isolation and security.

2. **ALB Module**: Configures the Application Load Balancer, sets up listeners and target groups to route traffic to EC2 instances in the Application layer.

3. **ASG Module**: Creates the Auto Scaling Group, defining launch configurations, scaling policies, and health checks for EC2 instances.

4. **EC2 Module**: Defines individual EC2 instances with specified configurations, such as instance type, AMI, and security groups.

5. **RDS Module**: Sets up the Relational Database Service, configuring database engine, instance type, storage, and backup options.
<br/><br/>

## Usage

To deploy the three-tier architecture using Terraform, follow these steps:

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>

2. **Configure AWS Credentials**:
   Ensure that you have AWS credentials configured with appropriate permissions.

3. **Initialize Terraform**:
   ```bash
   terraform init

4. **Review and Modify Variables**:
   Update variables in terraform.tfvars or provide values via command-line arguments as needed.

5. **Deploy Infrastructure**:
    ```bash
   terraform apply

7. **Accessing the Application**:
   Once the deployment is complete, access the application through the ALB DNS name.
<br/><br/>

## Monitoring

CloudWatch is utilized for monitoring and logging. Key metrics such as CPU utilization, network traffic, and database performance can be monitored through the AWS Management Console or programmatically using CloudWatch APIs.
<br/><br/>

## Contributing

Contributions to this project are welcome! Feel free to open issues or pull requests with suggestions, bug fixes, or improvements.
<br/><br/>

## License

This project is licensed under the MIT License.


