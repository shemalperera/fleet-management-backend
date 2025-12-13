# Security Group
resource "aws_security_group" "main" {
  name_prefix = "${var.project_name}-${var.environment}-sg"
  description = "Security group for ${var.project_name} ${var.environment}"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.environment}-sg"
    }
  )
}

# Ingress Rule - SSH (Port 22)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count             = var.enable_ssh ? 1 : 0
  security_group_id = aws_security_group.main.id

  description = "Allow SSH access"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = var.ssh_cidr_blocks[0]

  tags = merge(
    var.tags,
    {
      Name = "ssh-ingress"
    }
  )
}

# Ingress Rule - HTTPS (Port 443)
resource "aws_vpc_security_group_ingress_rule" "https" {
  count             = var.enable_https ? 1 : 0
  security_group_id = aws_security_group.main.id

  description = "Allow HTTPS access"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = var.https_cidr_blocks[0]

  tags = merge(
    var.tags,
    {
      Name = "https-ingress"
    }
  )
}

# Ingress Rule - HTTP (Port 80)
resource "aws_vpc_security_group_ingress_rule" "http" {
  count             = var.enable_http ? 1 : 0
  security_group_id = aws_security_group.main.id

  description = "Allow HTTP access"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = var.http_cidr_blocks[0]

  tags = merge(
    var.tags,
    {
      Name = "http-ingress"
    }
  )
}

# Kubernetes Ingress Rules - Control Plane
resource "aws_vpc_security_group_ingress_rule" "k8s_api_server" {
  security_group_id = aws_security_group.main.id

  description = "Kubernetes API Server"
  from_port   = 6443
  to_port     = 6443
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "k8s-api-server"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "k8s_etcd" {
  security_group_id = aws_security_group.main.id

  description = "etcd server client API"
  from_port   = 2379
  to_port     = 2380
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "k8s-etcd"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "k8s_kubelet" {
  security_group_id = aws_security_group.main.id

  description = "Kubelet API"
  from_port   = 10250
  to_port     = 10250
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "k8s-kubelet"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "k8s_scheduler" {
  security_group_id = aws_security_group.main.id

  description = "kube-scheduler"
  from_port   = 10259
  to_port     = 10259
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "k8s-scheduler"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "k8s_controller_manager" {
  security_group_id = aws_security_group.main.id

  description = "kube-controller-manager"
  from_port   = 10257
  to_port     = 10257
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "k8s-controller-manager"
    }
  )
}

# Kubernetes Ingress Rules - NodePort Services
resource "aws_vpc_security_group_ingress_rule" "k8s_nodeport" {
  security_group_id = aws_security_group.main.id

  description = "Kubernetes NodePort Services"
  from_port   = 30000
  to_port     = 32767
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "k8s-nodeport"
    }
  )
}

# Flannel/CNI - Pod network overlay
resource "aws_vpc_security_group_ingress_rule" "k8s_flannel_vxlan" {
  security_group_id = aws_security_group.main.id

  description = "Flannel VXLAN overlay network"
  from_port   = 8472
  to_port     = 8472
  ip_protocol = "udp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "k8s-flannel-vxlan"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "k8s_flannel_health" {
  security_group_id = aws_security_group.main.id

  description = "Flannel healthcheck"
  from_port   = 8472
  to_port     = 8472
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "k8s-flannel-health"
    }
  )
}

# Allow ICMP for debugging (ping between nodes)
resource "aws_vpc_security_group_ingress_rule" "icmp" {
  security_group_id = aws_security_group.main.id

  description = "Allow ICMP (ping) within VPC"
  from_port   = -1
  to_port     = -1
  ip_protocol = "icmp"
  cidr_ipv4   = var.vpc_cidr

  tags = merge(
    var.tags,
    {
      Name = "icmp-internal"
    }
  )
}

# Egress Rule - Allow all outbound traffic
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  security_group_id = aws_security_group.main.id

  description = "Allow all outbound traffic"
  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"

  tags = merge(
    var.tags,
    {
      Name = "allow-all-egress"
    }
  )
}
