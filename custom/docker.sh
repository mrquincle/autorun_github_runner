#!/bin/sh

echo "Create directory for docker"
mkdir ~/docker
cp ~/custom/.docker-compose.yml.private ~/docker/docker-compose.yml

echo "Update prerequisites"
sudo apt-get update
sudo apt-get install -y vim ca-certificates curl gnupg lsb-release

echo "Get keys to download an up-to-date docker version"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Download docker"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

echo "Add $USER to docker group and trigger group"
sudo usermod -aG docker $USER
newgrp docker

echo "Start docker"
sudo systemctl start docker

echo "Now run docker-compose yourself by: "
echo
echo "  cd ~/docker"
echo "  docker-compose up -d"
echo
echo "This runs the docker in detached state, check the logs with:"
echo
echo "  docker-compose logs"
echo
echo "And check the first message, the github action tokens expire fast!"
