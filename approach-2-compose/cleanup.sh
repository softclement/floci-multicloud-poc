#!/usr/bin/env bash
# Approach 2 clean-up (run from approach-2-compose/). Scoped to this stack only.
set -u
docker compose down -v --remove-orphans
docker images -q 'floci/*' | xargs -r docker rmi -f
echo "Stack removed. Docker itself is untouched."
