#fetch availablity zonese in the region and store them in a local variable
data "aws_availability_zones" "available" {
  state = "available"
} 

# Current account details
data "aws_caller_identity" "current" {}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
  
}

#Cluster Name
locals {
  cluster_name = "${var.cluster_name}-${random_string.suffix.result}"
}

#Cidr block for the VPC
locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = [ for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k+10) ]
  public_subnets  = [ for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k) ]

# Common tags for all resources
common_tags = {
  Environment = var.environment
  Project     = "Retail Store"
  Owner       = data.aws_caller_identity.current.account_id
  managed_by  = "terraform"
}
}

# Kubernetes subnets tags
locals{
  private_subnets_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"            = "1"
  }
  public_subnets_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
} 