#!/bin/bash
# Runs once at first boot: install nginx and publish a page with instance details (IMDSv2).
dnf install -y nginx
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
meta() { curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/$1"; }
cat > /usr/share/nginx/html/index.html <<HTML
<!doctype html>
<html><body style="font-family:sans-serif">
<h1>${project}: deployed with Terraform</h1>
<p>Instance: $(meta instance-id) (type $(meta instance-type))</p>
<p>Availability zone: $(meta placement/availability-zone)</p>
<p>Private IP: $(meta local-ipv4) &middot; Public IP: $(meta public-ipv4)</p>
<p>Artifacts bucket: ${bucket}</p>
</body></html>
HTML
systemctl enable --now nginx
