# =============================================================================
# Security Groups Modülü - Değişken Tanımları
# =============================================================================

variable "project_name" {
  description = "Proje adı (kaynak isimlendirmede kullanılır)"
  type        = string
}

variable "vpc_id" {
  description = "Security Group'ların oluşturulacağı VPC ID"
  type        = string
}
