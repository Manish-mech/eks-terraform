variable "aws_region" {
    type = string
    default = "us-east-1"
  
}

variable "aws_profile" {
    type = string
    default = "personal"

}

variable "cluster_name" {
    type = string
    default = "prod-eks"
}


variable "enable_nat" {
    type = bool
    default = true
    description = "If true, create NAT Gateway(s) for external outbound access. If false, rely on VPC endpoints and ECR pull-through."
}

variable "single_nat_gateway" {
  type    = bool
  default = false
}


variable "public_subnets_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets (one per AZ)"
  default     = [
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnets_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets (one per AZ)"
  default     = [
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  
}



