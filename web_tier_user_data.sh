#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
echo "Deploy a web server on AWS" | tee /var/www/html/index.html
