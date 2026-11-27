#!/usr/bin/env bash
set -e
sudo rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.asc
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"
echo "Docker installed. Run 'newgrp docker' (or re-open the WSL terminal) before using docker without sudo."
