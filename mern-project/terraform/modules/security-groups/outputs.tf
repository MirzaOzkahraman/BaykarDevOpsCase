# =============================================================================
# Security Groups Modülü - Çıktı Değerleri
# =============================================================================

output "eks_cluster_sg_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_sg_id" {
  description = "EKS Worker Node Security Group ID"
  value       = aws_security_group.eks_nodes.id
}
