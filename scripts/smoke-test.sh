#!/usr/bin/env bash
# Quick check: is every emulator answering?
# Part 1 = root URL of each port (404 is fine: it only proves something is listening)
# Part 2 = each emulator's health endpoint (the meaningful check)

echo "--- Port check (any HTTP code = listening) ---"
for item in "AWS:4566" "Azure:4577" "GCP:4588" "OCI:4599" "UI:4500"; do
  name="${item%%:*}"; port="${item##*:}"
  code=$(curl -s -o /dev/null -m 5 -w '%{http_code}' "http://localhost:${port}/" || true)
  printf '%-6s port %-5s -> HTTP %s\n' "$name" "$port" "${code:-000}"
done

echo "--- Health endpoints ---"
for item in "AWS:4566:/_floci/health" "Azure:4577:/_floci/health" "GCP:4588:/_floci-gcp/health" "OCI:4599:/_floci-oci/health"; do
  name="${item%%:*}"; rest="${item#*:}"; port="${rest%%:*}"; path="${rest#*:}"
  code=$(curl -s -o /dev/null -m 5 -w '%{http_code}' "http://localhost:${port}${path}" || true)
  printf '%-6s %-28s -> HTTP %s\n' "$name" "localhost:${port}${path}" "${code:-000}"
done

# Optional deeper AWS test (needs AWS CLI)
if command -v aws >/dev/null 2>&1; then
  echo "--- AWS S3 round trip ---"
  aws s3 mb s3://floci-poc-bucket
  aws s3 ls
  aws s3 rb s3://floci-poc-bucket
else
  echo "AWS CLI not found - skipping S3 test (see README: Install AWS CLI)"
fi

# Optional OCI test (needs OCI CLI)
if command -v oci >/dev/null 2>&1; then
  echo "--- OCI namespace ---"
  oci os ns get --endpoint http://localhost:4599
fi
