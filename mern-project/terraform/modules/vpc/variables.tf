# =============================================================================
# VPC Modülü - Değişken Tanımları
# =============================================================================

variable "project_name" {
  description = "Proje adı (kaynak isimlendirmede kullanılır)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR bloğu"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blokları (her AZ için bir tane)"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blokları (her AZ için bir tane)"
  type        = list(string)
}

variable "availability_zones" {
  description = "Kullanılacak Availability Zone listesi"
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "EKS cluster adı (subnet tag'leri için)"
  type        = string
}
