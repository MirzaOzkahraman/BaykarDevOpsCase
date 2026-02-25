# =============================================================================
# Terraform Değişken Tanımları (Input Variables)
# =============================================================================

variable "aws_region" {
  description = "AWS bölgesi"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Proje adı (kaynak isimlendirmede kullanılır)"
  type        = string
  default     = "mern-app"
}

variable "environment" {
  description = "Ortam adı (dev, staging, prod)"
  type        = string
  default     = "production"
}

# ---------------------------------------------------------------------------
# VPC Değişkenleri
# ---------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR bloğu"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blokları (her AZ için bir tane)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blokları (her AZ için bir tane)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

# ---------------------------------------------------------------------------
# EKS Değişkenleri
# ---------------------------------------------------------------------------
variable "eks_cluster_version" {
  description = "EKS Kubernetes versiyonu"
  type        = string
  default     = "1.29"
}

variable "eks_node_instance_type" {
  description = "EKS worker node instance tipi"
  type        = string
  default     = "t3.medium"
}

variable "eks_node_desired_size" {
  description = "İstenen worker node sayısı"
  type        = number
  default     = 2
}

variable "eks_node_min_size" {
  description = "Minimum worker node sayısı"
  type        = number
  default     = 1
}

variable "eks_node_max_size" {
  description = "Maksimum worker node sayısı"
  type        = number
  default     = 4
}
