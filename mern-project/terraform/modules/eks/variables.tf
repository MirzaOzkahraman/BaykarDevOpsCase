# =============================================================================
# EKS Modülü - Değişken Tanımları
# =============================================================================

variable "project_name" {
  description = "Proje adı (kaynak isimlendirmede kullanılır)"
  type        = string
}

variable "eks_cluster_version" {
  description = "EKS Kubernetes versiyonu"
  type        = string
}

variable "eks_node_instance_type" {
  description = "EKS worker node instance tipi"
  type        = string
}

variable "eks_node_desired_size" {
  description = "İstenen worker node sayısı"
  type        = number
}

variable "eks_node_min_size" {
  description = "Minimum worker node sayısı"
  type        = number
}

variable "eks_node_max_size" {
  description = "Maksimum worker node sayısı"
  type        = number
}

variable "private_subnet_ids" {
  description = "EKS node group'un çalışacağı private subnet ID'leri"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "EKS cluster'ın erişeceği public subnet ID'leri"
  type        = list(string)
}

variable "cluster_sg_id" {
  description = "EKS Cluster Security Group ID"
  type        = string
}
