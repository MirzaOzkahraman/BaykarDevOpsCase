# =============================================================================
# VPC Modülü - Çıktı Değerleri
# =============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet ID listesi"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet ID listesi"
  value       = aws_subnet.private[*].id
}

output "vpc_cidr_block" {
  description = "VPC CIDR bloğu"
  value       = aws_vpc.main.cidr_block
}
