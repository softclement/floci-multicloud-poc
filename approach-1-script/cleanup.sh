#!/usr/bin/env bash
# Approach 1 clean-up. Default = SCOPED (only Floci things).
# Run with:  bash cleanup.sh full   -> ALSO wipes ALL Docker data and uninstalls Docker.
set -u

echo ">> Stopping Floci"
floci stop 2>/dev/null || true
docker rm -f floci floci-az floci-gcp floci-oci floci-aws-ui floci-ui 2>/dev/null || true
docker images -q 'floci/*' | xargs -r docker rmi -f 2>/dev/null || true

echo ">> Removing Floci CLI + local AWS endpoint override"
sudo rm -f /usr/local/bin/floci
sed -i '/^endpoint_url = http:\/\/localhost:4566$/d' ~/.aws/config 2>/dev/null || true
sed -i '/export AWS_ENDPOINT_URL=http:\/\/localhost:4566/d' ~/.bashrc ~/.zshrc 2>/dev/null || true
unset AWS_ENDPOINT_URL

if [ "${1:-}" = "full" ]; then
  echo ">> FULL: removing ALL containers, images, volumes and Docker itself"
  docker rm -f $(docker ps -aq) 2>/dev/null || true
  docker rmi -f $(docker images -q) 2>/dev/null || true
  docker system prune -a --volumes -f
  sudo systemctl disable --now docker docker.socket
  sudo apt-get purge -y docker.io docker-compose-v2
  sudo apt-get autoremove -y --purge
  sudo rm -rf /var/lib/docker /var/lib/containerd /etc/docker ~/.docker
  sudo gpasswd -d "$USER" docker 2>/dev/null || true
  sudo groupdel docker 2>/dev/null || true
fi
echo "Clean-up finished."
