#!/usr/bin/env bash
# Back-compat wrapper: regenerates Alex bundle only.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${ROOT}/scripts/sync-employee-personality.sh" --employee alex
