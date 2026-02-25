# =============================================================================
# Terraform Çıktı Değerleri (Root Module)
# Alt modül çıktılarını dışarıya taşır
# =============================================================================

# ---------------------------------------------------------------------------
# VPC Çıktıları
# ---------------------------------------------------------------------------
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet ID listesi"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet ID listesi"
  value       = module.vpc.private_subnet_ids
}

# ---------------------------------------------------------------------------
# EKS Çıktıları
# ---------------------------------------------------------------------------
output "eks_cluster_name" {
  description = "EKS Cluster adı"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster API endpoint URL'i"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority" {
  description = "EKS Cluster CA sertifikası (base64)"
  value       = module.eks.cluster_certificate_authority
  sensitive   = true
}

# kubectl yapılandırması için komut
output "eks_configure_kubectl" {
  description = "kubectl yapilandirma komutu"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

# ---------------------------------------------------------------------------
# ECR Çıktıları
# ---------------------------------------------------------------------------
output "ecr_frontend_repository_url" {
  description = "Frontend ECR repository URL'i"
  value       = module.ecr.frontend_repository_url
}

output "ecr_backend_repository_url" {
  description = "Backend ECR repository URL'i"
  value       = module.ecr.backend_repository_url
}

# ECR login komutu
output "ecr_login_command" {
  description = "ECR login komutu"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}
