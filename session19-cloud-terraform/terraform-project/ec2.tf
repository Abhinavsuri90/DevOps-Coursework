# Latest Amazon Linux 2023 AMI for the region, looked up at plan time.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "web" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = templatefile("${path.module}/user_data.sh", {
    project = var.project
    bucket  = aws_s3_bucket.assets.bucket
  })
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  # The web page must be reachable as soon as the instance boots, so wait for the
  # subnet's route to the Internet Gateway (an explicit dependency).
  depends_on = [aws_route_table_association.public]

  tags = { Name = "${var.project}-web" }
}
