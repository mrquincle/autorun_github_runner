#!/bin/sh

# Assumed to be already installed
#sudo apt-get update
#sudo apt-get install ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose

sudo usermod -aG docker $USER

newgrp docker

sudo service docker start

echo "Create directory for docker"
mkdir ~/docker
cp ~/.custom/.docker-compose.yml.private ~/docker/docker-compose.yml

cd ~/docker

echo "Run docker-compose"
docker-compose up
