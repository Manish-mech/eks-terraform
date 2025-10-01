# EKS Setup with Terraform

This project provisions a **highly available and secure Amazon EKS (Elastic Kubernetes Service) cluster** on AWS using **Terraform Infrastructure as Code (IaC)**, following AWS and Terraform best practices.

## Key Features

- ✅ **Official Terraform AWS Modules** – Uses the well-maintained [`terraform-aws-modules`](https://github.com/terraform-aws-modules) for EKS, VPC, and related resources to ensure reliability and standardization.  
- 🌐 **Dedicated VPC** – Custom VPC with **public and private subnets** distributed across **3 Availability Zones** for high availability.  
- 🔒 **Secure Networking** –  
  - **NAT Gateways** for secure outbound internet access from private subnets.  
  - **Public and Private Route Tables** with well-defined routing configurations.  
  - **VPC Endpoints (Gateway & Interface)** to securely connect to AWS services without traversing the public internet.  
- 📈 **Best Practices** – Infrastructure designed with scalability, security, and cost efficiency in mind.  

## Repository Structure

```
eks_prod_terraform/
├── providers.tf      # provider needed in Terraform
├── vpc.tf            # Root Terraform configuration
├── variables.tf      # Input variables
├── outputs.tf        # Outputs
└── README.md         # Project documentation
```
## VPC Architecture Diagram
![VPC infrastructure](https://github.com/Manish-mech/eks-terraform/blob/main/images/vpc_architecture.png)



## Getting Started

### Prerequisites
- Terraform >= 1.5.7,<2.0.0
- AWS CLI configured with appropriate credentials, I have used the profile method. 
- An AWS account with permissions for EKS, VPC, IAM, and related services  

### Deployment Steps
```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the infrastructure
terraform apply

