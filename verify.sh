#!/usr/bin/env bash
set -euo pipefail

A="${A:-node01}"
B="${B:-node02}"
PORT="${PORT:-9000}"
MSG="manual-check $(date -Iseconds) from ${A} -> ${B}"

echo "Sending UDP from ${A} to ${B}:${PORT}: '$MSG'"
docker exec "$A" /bin/sh -lc "printf '%s\n' '$MSG' | nc -u -w 1 ${B} ${PORT}"

echo
echo "Last 20 lines from ${B} (should show the received datagram):"
docker logs "$B" --tail=20