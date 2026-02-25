# =============================================================================
# Terraform Ana Konfigürasyon - Provider, Backend ve Modül Çağrıları
# =============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # ---------------------------------------------------------------------------
  # Remote State Backend (S3 + DynamoDB)
  # İlk kullanımda S3 bucket ve DynamoDB tablosu oluşturulmalı:
  #   aws s3 mb s3://mern-terraform-state-<ACCOUNT_ID>
  #   aws dynamodb create-table --table-name mern-terraform-lock \
  #     --attribute-definitions AttributeName=LockID,AttributeType=S \
  #     --key-schema AttributeName=LockID,KeyType=HASH \
  #     --billing-mode PAY_PER_REQUEST
  # ---------------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "mern-terraform-state-ACCOUNT-ID"
  #   key            = "mern-project/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "mern-terraform-lock"
  #   encrypt        = true
  # }
}

# AWS Provider yapılandırması
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Mevcut AWS hesap bilgilerini al (ECR URL oluşturmak için)
data "aws_caller_identity" "current" {}

# Mevcut bölgedeki AZ'leri al
data "aws_availability_zones" "available" {
  state = "available"
}

# =============================================================================
# Modül Çağrıları
# Bağımlılık sırası: VPC → Security Groups → EKS → ECR
# =============================================================================

# ---------------------------------------------------------------------------
# 1. VPC Modülü - Ağ altyapısı
# ---------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  eks_cluster_name     = "${var.project_name}-eks"
}

# ---------------------------------------------------------------------------
# 2. Security Groups Modülü - Güvenlik kuralları
# ---------------------------------------------------------------------------
module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# ---------------------------------------------------------------------------
# 3. EKS Modülü - Kubernetes cluster
# ---------------------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  project_name           = var.project_name
  eks_cluster_version    = var.eks_cluster_version
  eks_node_instance_type = var.eks_node_instance_type
  eks_node_desired_size  = var.eks_node_desired_size
  eks_node_min_size      = var.eks_node_min_size
  eks_node_max_size      = var.eks_node_max_size
  private_subnet_ids     = module.vpc.private_subnet_ids
  public_subnet_ids      = module.vpc.public_subnet_ids
  cluster_sg_id          = module.security_groups.eks_cluster_sg_id
}

# ---------------------------------------------------------------------------
# 4. ECR Modülü - Container image depoları
# ---------------------------------------------------------------------------
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}
