#!/usr/bin/env bash
# Back-compat: runs full employee personality check (Alex + Tim + …).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "${ROOT}/scripts/check-employee-personality.sh"
