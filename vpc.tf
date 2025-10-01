data "aws_availability_zones" "available" {}

locals {
  desired_az_count = 3
  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    min(length(data.aws_availability_zones.available.names), local.desired_az_count)
  )

  public_subnets_used = slice(var.public_subnets_cidrs,0,length(local.azs))
  private_subnets_used = slice(var.private_subnets_cidrs, 0, length(local.azs))
}

module "vpc" {
    source = "terraform-aws-modules/vpc/aws"
    version = "~> 5.16.0"

    name = "${var.cluster_name}-vpc"
    cidr = var.vpc_cidr !="" ? var.vpc_cidr : "10.0.0.0/16"

    azs = local.azs
    public_subnets = local.public_subnets_used
    private_subnets = local.private_subnets_used

    enable_nat_gateway = var.enable_nat

    single_nat_gateway = var.single_nat_gateway
    one_nat_gateway_per_az = var.enable_nat && !var.single_nat_gateway

  # DNS and hostnames (important for k8s, service discovery)
    enable_dns_support   = true
    enable_dns_hostnames = true

  map_public_ip_on_launch = true

  public_subnet_tags = {
    Name = "${var.cluster_name}-public"
    "kubernetes.io/role/elb" = "1"
    Tier = "public"
  }


  private_subnet_tags = {
    Name = "${var.cluster_name}-private"
    "kubernetes.io/role/internal-elb" = "1"
    Tier = "Private"
  }


}

resource "aws_security_group" "vpc_endpoint" {
  name        = "${var.cluster_name}-vpce-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = module.vpc.vpc_id

  # Allow HTTPS from private subnets (where EKS nodes run)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-vpce-sg"
  }
}


module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "~> 5.16.0"

  vpc_id         = module.vpc.vpc_id
  security_group_ids = [aws_security_group.vpc_endpoint.id]

  endpoints = {
    s3 = {
      service         = "s3"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "s3-endpoint" }
    }
    dynamodb = {
      service         = "dynamodb"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "dynamodb-endpoint" }
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
      tags                = { Name = "ecr-dkr-endpoint" }
    }
    ecr_api = {
      service             = "ecr.api"
      subnet_ids          = module.vpc.private_subnets
      private_dns_enabled = true
      tags                = { Name = "ecr-api-endpoint" }
    }
  }

  depends_on = [module.vpc]
}


