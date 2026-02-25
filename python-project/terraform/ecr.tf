# =============================================================================
# Python ETL - ECR Repository & IAM Politikaları
# =============================================================================

# ---------------------------------------------------------------------------
# ECR Repository - Python ETL Docker image deposu
# ---------------------------------------------------------------------------
resource "aws_ecr_repository" "python_etl" {
  name                 = "mern-python-etl"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true # Her push'ta güvenlik taraması
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "${var.project_name}-ecr"
  }
}

# ---------------------------------------------------------------------------
# ECR Lifecycle Policy - Eski image'ları otomatik temizle
# ---------------------------------------------------------------------------
resource "aws_ecr_lifecycle_policy" "python_etl" {
  repository = aws_ecr_repository.python_etl.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Untagged imagelari 3 gun sonra sil"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Son 5 tagged image tut"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# IAM Policy - ETL CronJob'un ECR'dan image çekmesi için
# Mevcut EKS Node Role'üne ek ECR izni ekler
# ---------------------------------------------------------------------------
resource "aws_iam_policy" "etl_ecr_access" {
  name        = "${var.project_name}-ecr-access"
  description = "Python ETL CronJob icin ECR erisim izni"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = aws_ecr_repository.python_etl.arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ecr-access-policy"
  }
}

# IAM Policy'yi mevcut EKS Node Role'üne bağla
resource "aws_iam_role_policy_attachment" "etl_ecr_access" {
  policy_arn = aws_iam_policy.etl_ecr_access.arn
  role       = tolist(data.aws_eks_node_group.existing.resources[0].remote_access_security_group_ids)[0] != "" ? "${var.eks_cluster_name}-eks-node-role" : "${var.eks_cluster_name}-eks-node-role"
}

# ---------------------------------------------------------------------------
# IAM Policy - ETL Script'in CloudWatch Logs'a yazması için (opsiyonel)
# ---------------------------------------------------------------------------
resource "aws_iam_policy" "etl_cloudwatch_logs" {
  name        = "${var.project_name}-cloudwatch-logs"
  description = "Python ETL CronJob icin CloudWatch Logs izni"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/python-etl/*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-cloudwatch-logs-policy"
  }
}
