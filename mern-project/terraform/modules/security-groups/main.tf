# =============================================================================
# Security Groups Modülü - Minimum Yetki Prensibi (Least Privilege)
# =============================================================================

# ---------------------------------------------------------------------------
# EKS Cluster Security Group
# ---------------------------------------------------------------------------
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.project_name}-eks-cluster-"
  description = "EKS Cluster control plane security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-eks-cluster-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Cluster → dışarı tüm trafik
resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Cluster tum cikis trafigine izin ver"
}

# ---------------------------------------------------------------------------
# EKS Node Security Group
# ---------------------------------------------------------------------------
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-eks-nodes-"
  description = "EKS Worker node security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-eks-nodes-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Node'lardan dış dünyaya erişim
resource "aws_security_group_rule" "nodes_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Node tum cikis trafigine izin ver"
}

# Node'lar arası iletişim (pod-to-pod)
resource "aws_security_group_rule" "nodes_internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Nodelar arasi tum trafige izin ver"
}

# Cluster → Node iletişimi (kubelet, kube-proxy)
resource "aws_security_group_rule" "cluster_to_nodes" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Cluster dan node lara TCP iletisimi"
}

# Cluster → Node HTTPS (443)
resource "aws_security_group_rule" "cluster_to_nodes_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  security_group_id        = aws_security_group.eks_nodes.id
  description              = "Cluster dan node lara HTTPS iletisimi"
}

# Node → Cluster API Server
resource "aws_security_group_rule" "nodes_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  security_group_id        = aws_security_group.eks_cluster.id
  description              = "Node lardan cluster API server a HTTPS erisimi"
}
