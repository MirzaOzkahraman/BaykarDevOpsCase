# =============================================================================
# Terraform Varsayılan Değerler
# Projeye özel ayarlar burada tanımlanır
# =============================================================================

aws_region   = "eu-west-1"
project_name = "mern-app"
environment  = "production"

# VPC
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# EKS
eks_cluster_version    = "1.30"
eks_node_instance_type = "t3.medium"
eks_node_desired_size  = 2
eks_node_min_size      = 1
eks_node_max_size      = 4
