#!/bin/bash
echo "Deploying Web Apps On NGINX"

echo "Updating System"
sudo apt update -y

echo "Install Utilities"
sudo apt install -y zip unzip

echo "Install NGINX"
sudo apt install -y nginx

echo "Remove Old Files"
sudo rm -r /var/www/html

echo "Deploy Login App"
sudo git clone  https://github.com/ravi2krishna/ecomm.git /var/www/html

echo "Deployed Web Apps On NGINX"