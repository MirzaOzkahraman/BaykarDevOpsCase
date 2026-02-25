# =============================================================================
# EKS Modülü - Çıktı Değerleri
# =============================================================================

output "cluster_name" {
  description = "EKS Cluster adı"
  value       = aws_eks_cluster.main.name
}

output "cluster_endpoint" {
  description = "EKS Cluster API endpoint URL'i"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority" {
  description = "EKS Cluster CA sertifikası (base64)"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "node_group_name" {
  description = "EKS Node Group adı"
  value       = aws_eks_node_group.main.node_group_name
}
