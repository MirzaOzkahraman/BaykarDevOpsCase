# =============================================================================
# Python ETL Terraform - Çıktı Değerleri
# =============================================================================

output "ecr_repository_url" {
  description = "Python ETL ECR repository URL'i"
  value       = aws_ecr_repository.python_etl.repository_url
}

output "ecr_repository_arn" {
  description = "Python ETL ECR repository ARN"
  value       = aws_ecr_repository.python_etl.arn
}

output "eks_cluster_endpoint" {
  description = "Mevcut EKS Cluster endpoint (referans)"
  value       = data.aws_eks_cluster.existing.endpoint
}

output "ecr_login_command" {
  description = "ECR login komutu"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}
