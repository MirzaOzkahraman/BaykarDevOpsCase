# =============================================================================
# ECR Modülü - Çıktı Değerleri
# =============================================================================

output "frontend_repository_url" {
  description = "Frontend ECR repository URL'i"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_repository_url" {
  description = "Backend ECR repository URL'i"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_arn" {
  description = "Frontend ECR repository ARN"
  value       = aws_ecr_repository.frontend.arn
}

output "backend_repository_arn" {
  description = "Backend ECR repository ARN"
  value       = aws_ecr_repository.backend.arn
}
