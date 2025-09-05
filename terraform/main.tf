#VPC 
 module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

# NAT Gateway configuration
  enable_nat_gateway = true
  single_nat_gateway  = var.enable_single_nat_gateway

  # create igw
  create_igw = true

# DNS support
  enable_dns_hostnames = true
  enable_dns_support   = true

# Manage default resources
  
  manage_default_network_acl = true
  default_network_acl_tags = { Name = "${var.cluster_name}-default-nacl"}
  manage_default_route_table = true
  default_route_table_tags = { Name = "${var.cluster_name}-default-rt"}
  manage_default_security_group = true
  default_security_group_tags = { Name = "${var.cluster_name}-default-sg"}

# Kubernetes subnet tags
  private_subnet_tags = merge(local.common_tags, local.private_subnets_tags)
  public_subnet_tags  = merge(local.common_tags, local.public_subnets_tags)


  tags = local.common_tags
   
 }

 module "retail_app_eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name = local.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true  

  enable_cluster_creator_admin_permissions = true

    cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_kms_key = true
  kms_key_description = "KMS key for EKS cluster ${local.cluster_name}"
  kms_key_deletion_window_in_days = 7

  tags = local.common_tags
 }