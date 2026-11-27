#!/usr/bin/env bash
# Approach 1 - Floci CLI (AWS) + docker run (Azure, GCP, OCI, UI)
set -e

# 1. Install Docker
sudo rm -f /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.asc
sudo apt-get update
sudo apt-get install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# 2. Install Floci CLI
curl -fsSL https://floci.io/install.sh | sh

# 3. Dummy AWS credentials + region for local CLI/SDKs
mkdir -p ~/.aws

cat << 'EOF' > ~/.aws/credentials
[default]
aws_access_key_id = test
aws_secret_access_key = test
EOF

cat << 'EOF' > ~/.aws/config
[default]
region = us-east-1
output = json
endpoint_url = http://localhost:4566
EOF

# 4. Start all 4 cloud runtimes + UI (sg docker = use new docker group without re-login)
sg docker -c '
  floci start --pull always

  docker run -d --name floci-az  -p 4577:4577 -v /var/run/docker.sock:/var/run/docker.sock floci/floci-az:latest
  docker run -d --name floci-gcp -p 4588:4588 -v /var/run/docker.sock:/var/run/docker.sock floci/floci-gcp:latest
  docker run -d --name floci-oci -p 4599:4599 -v /var/run/docker.sock:/var/run/docker.sock floci/floci-oci:latest

  # Do NOT open http://localhost:4566/_floci/ui - that makes Floci start its own AWS-only console on :4500.
  # Pull the console image directly and run the standalone console (no FLOCI_CLOUD = serves every cloud).
  docker pull floci/floci-ui:latest
  docker rm -f floci-aws-ui floci-ui 2>/dev/null || true
  docker run -d --name floci-aws-ui \
    --network host \
    -e AWS_ACCESS_KEY_ID=test \
    -e AWS_SECRET_ACCESS_KEY=test \
    -e AWS_DEFAULT_REGION=us-east-1 \
    -e AWS_ENDPOINT_URL=http://localhost:4566 \
    -e FLOCI_AZURE_ENDPOINT=http://localhost:4577 \
    -e FLOCI_GCP_ENDPOINT=http://localhost:4588 \
    -e FLOCI_OCI_ENDPOINT=http://localhost:4599 \
    floci/floci-ui:latest
'
echo "Installation finished."
bash "$(dirname "$0")/../scripts/endpoints.sh"
