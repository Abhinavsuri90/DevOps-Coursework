output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "public_subnet_azs" {
  value = aws_subnet.public[*].availability_zone
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "cluster_version" {
  value = aws_eks_cluster.main.version
}

output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "node_group_status" {
  value = aws_eks_node_group.default.status
}

output "kubeconfig_command" {
  description = "Run this to point kubectl at the new cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
}
