# =============================================================================
# Python ETL Terraform - Değişken Tanımları
# =============================================================================

variable "aws_region" {
  description = "AWS bölgesi"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Ortam adı"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Proje adı"
  type        = string
  default     = "python-etl"
}

variable "eks_cluster_name" {
  description = "Mevcut EKS Cluster adı (MERN projesinden)"
  type        = string
  default     = "mern-app-eks"
}

variable "eks_node_group_name" {
  description = "Mevcut EKS Node Group adı"
  type        = string
  default     = "mern-app-node-group"
}
