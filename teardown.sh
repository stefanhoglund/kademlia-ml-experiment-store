#!/usr/bin/env bash
set -euo pipefail
NET="p2p-net"


for i in $(seq -f "%02g" 1 200); do
  c="node${i}"
  if docker ps -a --format '{{.Names}}' | grep -qx "$c"; then
    docker rm -f "$c" >/dev/null || true
  fi
done
docker network rm "$NET" >/dev/null || true
echo "Cleaned up."