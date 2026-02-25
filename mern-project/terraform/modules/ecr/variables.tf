# =============================================================================
# ECR Modülü - Değişken Tanımları
# =============================================================================

variable "project_name" {
  description = "Proje adı (kaynak isimlendirmede kullanılır)"
  type        = string
}

variable "image_retention_count" {
  description = "Tutulacak tagged image sayısı"
  type        = number
  default     = 10
}

variable "untagged_image_expiry_days" {
  description = "Untagged image'ların kaç gün sonra silineceği"
  type        = number
  default     = 3
}
