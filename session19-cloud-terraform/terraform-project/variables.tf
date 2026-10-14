variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "ap-south-1"
}

variable "project" {
  description = "Name prefix for every resource."
  type        = string
  default     = "abhinav-s19"
}

variable "owner" {
  description = "Owner tag."
  type        = string
  default     = "Abhinav"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC."
  type        = string
  default     = "10.19.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block of the public subnet (must be inside vpc_cidr)."
  type        = string
  default     = "10.19.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro is free-tier eligible)."
  type        = string
  default     = "t3.micro"
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed to SSH on port 22. Empty = no SSH (use SSM or the web page instead)."
  type        = list(string)
  default     = []
}
