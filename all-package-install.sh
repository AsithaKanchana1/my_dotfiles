#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "This entrypoint is kept for compatibility."
echo "Running scripts/install-packages.sh with --extended..."
"$SCRIPT_DIR/scripts/install-packages.sh" --extended


