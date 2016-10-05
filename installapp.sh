#!/bin/bash
echo "Hello, Running apache updates"

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install apache2 -y

echo "Running apt-get update command"

curl -O https://bootstrap.pypa.io/get-pip.py

sudo python get-pip.py

echo "Installing pip.py"

sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install apache2 -y apache2-doc apache2-utils -y
sudo apt-get install awscli -y
