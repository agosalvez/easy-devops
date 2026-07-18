#!/usr/bin/env bash
set -euo pipefail

forbidden='(^|/)(acme\.json|\.env|.*\.pem|.*\.key)$'
tracked="$(git ls-files)"
if grep -E "$forbidden" <<<"$tracked"; then
  echo "Generated secrets or runtime configuration are tracked" >&2
  exit 1
fi
