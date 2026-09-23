#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for command_name in node cloudflared; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: $command_name is not installed."
    echo "Node.js: https://nodejs.org"
    echo "Cloudflared: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/"
    exit 1
  fi
done

export PORT="${PORT:-3000}"
node server.js &
server_pid=$!
cleanup() {
  kill "$server_pid" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

ready=0
for _ in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:${PORT}/api/health" >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 0.5
done

if [ "$ready" -ne 1 ]; then
  echo "ERROR: The platform server did not start on port ${PORT}."
  exit 1
fi

echo "The public HTTPS URL will appear below."
echo "Keep this terminal and computer running. Press Ctrl+C to stop."
if [ -n "${CLOUDFLARE_TUNNEL_TOKEN:-}" ]; then
  cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARE_TUNNEL_TOKEN"
else
  cloudflared tunnel --no-autoupdate --url "http://127.0.0.1:${PORT}"
fi