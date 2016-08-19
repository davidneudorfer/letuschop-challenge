#!/bin/bash -eux

curl -s -o "awscli-bundle.zip" "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
sudo apt-get install unzip
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
aws --version
