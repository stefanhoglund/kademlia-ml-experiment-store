#!/usr/bin/env bash
set -euo pipefail

IMG="udp-node:latest"
NET="p2p-net"
COUNT="${COUNT:-5}"
PORT="${PORT:-9000}"
INTERVAL="${INTERVAL:-15}"

docker build -t "$IMG" .

# Create user-defined bridge (embedded DNS = name->IP)
docker network inspect "$NET" >/dev/null 2>&1 || docker network create "$NET"

# node01 .. nodeNN
NAMES=()
for i in $(seq -f "%02g" 1 "$COUNT"); do NAMES+=("node${i}"); done
PEERS="${NAMES[*]}"

# Launch
for name in "${NAMES[@]}"; do
  docker run -d --restart unless-stopped \
    --name "$name" \
    --hostname "$name" \
    --network "$NET" \
    -e PORT="$PORT" \
    -e INTERVAL="$INTERVAL" \
    -e PEERS="$PEERS" \
    "$IMG" >/dev/null
done

echo "Started $COUNT UDP nodes on '$NET' (port $PORT). Example:"
echo "  docker logs -f ${NAMES[0]}"