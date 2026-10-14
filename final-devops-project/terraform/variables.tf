variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "owner" {
  description = "Owner tag."
  type        = string
  default     = "Abhinav"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "spendwise-eks"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version. null = the current EKS default."
  type        = string
  default     = null
}

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.21.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "One public subnet per Availability Zone (EKS needs at least two AZs)."
  type        = list(string)
  default     = ["10.21.1.0/24", "10.21.2.0/24"]
}

variable "node_instance_type" {
  description = "Worker node instance type."
  type        = string
  default     = "t3.small"
}

variable "node_desired_size" {
  description = "Number of worker nodes."
  type        = number
  default     = 1
}
