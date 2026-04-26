#!/bin/sh
set -eu

PORT="${PORT:-9000}"
PEERS="${PEERS:-}"     # space-separated list of container names
HOSTNAME="$(hostname)"

echo "Sprint 0 - [$(date -Iseconds)] ${HOSTNAME} starting UDP echo on :${PORT}"


(
  while true; do
    socat -v -T1 -u UDP-RECVFROM:${PORT},fork,reuseaddr SYSTEM:'cat'
  done
) &

# Small delay to let everyone start
sleep 3

# Periodic any-to-any sends
while true; do
  NOW="$(date -Iseconds)"
  for p in $PEERS; do
    [ "$p" = "$HOSTNAME" ] && continue
    MSG="[$NOW] ${HOSTNAME} -> ${p} : hello"
    # send UDP datagram; best-effort; ignore errors if peer not ready
    printf '%s\n' "$MSG" | nc -u -w 1 "$p" "$PORT" || true
    echo "[$(date -Iseconds)] sent to ${p}"
  done
  sleep "$INTERVAL"
done