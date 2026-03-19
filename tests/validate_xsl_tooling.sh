#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  echo "$1"
  exit 1
}

command -v xmllint >/dev/null 2>&1 || fail "Validation failed: xmllint is required."
command -v xsltproc >/dev/null 2>&1 || fail "Validation failed: xsltproc is required."

find xsl -type f -name '*.xsl' -print0 | while IFS= read -r -d '' file; do
  xmllint --noout "$file"
done

python3 tools/build_xsl.py xsl/main.xsl "$TMP_DIR/built.xsl"
xmllint --noout "$TMP_DIR/built.xsl"
xsltproc -o "$TMP_DIR/report.html" "$TMP_DIR/built.xsl" samples/nmap-scan.xml

echo "XSL tooling validation passed"
