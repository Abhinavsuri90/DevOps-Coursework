output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.web.id
}

output "instance_id" {
  value = aws_instance.web.id
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "web_url" {
  description = "Open this in a browser about a minute after apply."
  value       = "http://${aws_instance.web.public_dns}"
}

output "assets_bucket" {
  value = aws_s3_bucket.assets.bucket
}
