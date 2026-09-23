#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v node >/dev/null 2>&1; then
  echo "ERROR: Node.js is not installed."
  echo "Install Node.js from https://nodejs.org and run this script again."
  exit 1
fi

export PORT="${PORT:-3000}"
echo "Pedagogical Platform - Local Network"
echo "Keep this terminal and computer running."
exec node server.js