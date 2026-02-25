# =============================================================================
# Python ETL Terraform - Ana Konfigürasyon
# Mevcut EKS Cluster'a data source ile referans verir
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
  # MERN projesinden bağımsız ayrı state dosyası
  # ---------------------------------------------------------------------------
  # backend "s3" {
  #   bucket         = "mern-terraform-state-ACCOUNT-ID"
  #   key            = "python-project/terraform.tfstate"
  #   region         = "eu-west-1"
  #   dynamodb_table = "mern-terraform-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "python-etl"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ---------------------------------------------------------------------------
# Data Sources - Mevcut altyapıya referans
# MERN projesinde oluşturulan VPC ve EKS cluster'ı kullanır
# ---------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

# Mevcut EKS Cluster bilgilerini al
data "aws_eks_cluster" "existing" {
  name = var.eks_cluster_name
}

# Mevcut EKS Node Group IAM Role'ünü al
data "aws_eks_node_group" "existing" {
  cluster_name    = var.eks_cluster_name
  node_group_name = var.eks_node_group_name
}
