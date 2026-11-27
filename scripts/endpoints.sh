#!/usr/bin/env bash
# Prints the endpoint / console table (used at the end of both approaches)
cat << 'EOF'

Cloud   Emulator image     API endpoint            Console URL
------  -----------------  ----------------------  ------------------------------------
AWS     floci/floci        http://localhost:4566   http://localhost:4500/console/aws
Azure   floci/floci-az     http://localhost:4577   http://localhost:4500/console/azure
GCP     floci/floci-gcp    http://localhost:4588   http://localhost:4500/console/gcp
OCI     floci/floci-oci    http://localhost:4599   http://localhost:4500/console/oci

EOF
