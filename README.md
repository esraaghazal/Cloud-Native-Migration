# Cloud-Native-Migration
migrate on prim to native cloud
# VProfile AWS Infrastructure with Terraform

## Overview

This project provisions and deploys the VProfile application on AWS using Terraform.

The infrastructure follows a multi-tier architecture and includes networking, compute, database, caching, messaging, and load balancing components.

---

# Architecture

- Custom VPC
- Public and Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups
- Bastion Host
- Application Servers (Tomcat)
- Application Load Balancer (ALB)
- Amazon RDS (MySQL)
- Amazon ElastiCache (Memcached)
- Amazon MQ (RabbitMQ)
- Route53 Private Hosted Zone

---

# AWS Services Used

- Amazon VPC
- Amazon EC2
- Amazon RDS MySQL
- Amazon ElastiCache
- Amazon MQ (RabbitMQ)
- Application Load Balancer
- Route53 Private Hosted Zone
- Internet Gateway
- NAT Gateway
- Elastic IP
- Security Groups

---

# Infrastructure Layout

<img width="1280" height="853" alt="image" src="https://github.com/user-attachments/assets/1d769f95-9b41-4cac-a004-a5170e107640" />


# Project Structure

```
terraform-vprofile/
│
├── provider.tf
├── versions.tf
├── variables.tf
├── terraform.tfvars
├── outputs.tf
│
├── main.tf
├── ec2.tf
├── rds.tf
├── elasticache.tf
├── mq.tf
├── alb.tf
├── bastion.tf
├── route53.tf
│
└── README.md
```

---

# Prerequisites

- Terraform
- AWS CLI
- Configured AWS Credentials
- Existing EC2 Key Pair
- Git

---

# Deployment

Initialize Terraform

```bash
terraform init
```

Validate configuration

```bash
terraform validate
```

Review execution plan

```bash
terraform plan
```

Deploy infrastructure

```bash
terraform apply
```

Destroy infrastructure

```bash
terraform destroy
```

---

# Application Deployment

After infrastructure provisioning:

1. Connect to Bastion Host.

2. SSH into Tomcat servers.

3. Execute the Tomcat deployment script.

4. Clone the application repository.

5. Update `application.properties`.

6. Build the application using Maven.

7. Deploy the generated WAR file.


<img width="1918" height="1015" alt="Screenshot 2026-07-13 205318" src="https://github.com/user-attachments/assets/ca1856d2-2abd-4fcf-9bb0-83e263b7dac7" />


---

# Database Configuration

```
Host: db01.vprofile
Port: 3306
Database: accounts
Username: admin
Password: ********
```

---

# Memcached Configuration

```
Host: mc01.vprofile
Port: 11211
```

<img width="1918" height="1018" alt="Screenshot 2026-07-13 205159" src="https://github.com/user-attachments/assets/92dfc225-3c38-40ac-9a36-e14b226f9491" />


<img width="1918" height="1015" alt="Screenshot 2026-07-13 205146" src="https://github.com/user-attachments/assets/ffd31522-c9d3-4405-bdd6-84f8e6436f38" />


---

# RabbitMQ Configuration

```
Host: rmq01.vprofile
Port: 5672
Username: admin
Password: ********
```

---

# Route53 Records

| Record | Target |
|---------|--------|
| db01.vprofile | Amazon RDS |
| mc01.vprofile | ElastiCache |
| rmq01.vprofile | Amazon MQ |

---

# Security

- Application servers deployed in private subnets.
- Database accessible only from application security group.
- Memcached accessible only from application servers.
- RabbitMQ accessible only from application servers.
- Bastion Host used for administrative SSH access.
- Internet access to private instances through NAT Gateway.

---

# Outputs

Terraform outputs include:

- ALB DNS Name
- RDS Endpoint
- Memcached Endpoint
- RabbitMQ Endpoint
- Bastion Public IP

---

# Technologies

- Terraform
- AWS
- Tomcat
- Maven
- Java
- MySQL
- RabbitMQ
- Memcached
- Route53

---

<img width="1912" height="886" alt="Screenshot 2026-07-13 205753" src="https://github.com/user-attachments/assets/4699206a-a85e-4aea-b06d-dc2ae112100b" />

