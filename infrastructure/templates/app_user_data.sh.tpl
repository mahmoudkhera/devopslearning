#!/bin/bash

set -e 
set -o

apt-get update -y
apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -


add-apt-repository "deb https://download.docker.com/linux/ubuntu focal stable"


apt-get update -y
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io

systemctl start docker
systemctl enable docker


usermod -aG docker ubuntu

