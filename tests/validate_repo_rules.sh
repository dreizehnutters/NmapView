#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "$1"
  exit 1
}

if find tools -type d -name '__pycache__' | grep -q .; then
  fail "Repository hygiene check failed: remove committed __pycache__ directories under tools/."
fi

if rg -n 'innerHTML\s*=' xsl >/dev/null; then
  fail "Repository hygiene check failed: innerHTML assignment is not allowed in xsl/ scripts."
fi

if rg -n 'target="_blank"' xsl/web.xsl | grep -v 'rel="noopener noreferrer"' >/dev/null; then
  fail "Repository hygiene check failed: target=_blank links must include rel=\"noopener noreferrer\"."
fi

if rg -n '<script' xsl/services.xsl xsl/inventory.xsl xsl/hosts.xsl xsl/web.xsl >/dev/null; then
  fail "Repository hygiene check failed: feature templates must not emit inline <script> tags."
fi

echo "Repository rules validation passed"
