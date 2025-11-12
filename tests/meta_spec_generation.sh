#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
cd "$ROOT_DIR"

# Create a meta spec and capture the created path
OUTPUT_META=$(make spec TITLE='meta: テスト用メタ仕様')
CREATED_META_PATH=$(echo "$OUTPUT_META" | awk '/Created:/ {print $2}')

if [[ -z "${CREATED_META_PATH:-}" || ! -f "$CREATED_META_PATH" ]]; then
  echo "[FAIL] meta spec not created or path not found" >&2
  echo "$OUTPUT_META" >&2
  exit 1
fi

META_BASENAME=$(basename "$CREATED_META_PATH")
# 2パターン許容: meta-<slug>-<stamp>.md もしくは slug が meta の場合は meta-<stamp>.md
if [[ "$META_BASENAME" =~ ^meta-[0-9]{8}-[0-9]{6}\.md$ ]]; then
  : # OK 縮約パターン
elif [[ "$META_BASENAME" =~ ^meta-[a-z0-9-]+-[0-9]{8}-[0-9]{6}\.md$ ]]; then
  : # OK 通常パターン
else
  echo "[FAIL] meta filename pattern mismatch: $META_BASENAME" >&2
  exit 1
fi

# Content check: title starts with 'Spec: meta:'
if ! head -n 1 "$CREATED_META_PATH" | grep -q '^# Spec: meta:'; then
  echo "[FAIL] meta spec title does not start with 'meta:'" >&2
  exit 1
fi

# Create a normal spec and ensure it does NOT use meta- prefix and DOES use STAMP-first
OUTPUT_NORMAL=$(make spec TITLE='通常機能の仕様テスト')
CREATED_NORMAL_PATH=$(echo "$OUTPUT_NORMAL" | awk '/Created:/ {print $2}')

if [[ -z "${CREATED_NORMAL_PATH:-}" || ! -f "$CREATED_NORMAL_PATH" ]]; then
  echo "[FAIL] normal spec not created or path not found" >&2
  echo "$OUTPUT_NORMAL" >&2
  exit 1
fi

NORMAL_BASENAME=$(basename "$CREATED_NORMAL_PATH")
if [[ "$NORMAL_BASENAME" == meta-* ]]; then
  echo "[FAIL] normal spec unexpectedly uses meta- prefix: $NORMAL_BASENAME" >&2
  exit 1
fi
if [[ ! "$NORMAL_BASENAME" =~ ^[0-9]{8}-[0-9]{6}-[a-z0-9-]+\.md$ ]]; then
  echo "[FAIL] normal spec filename pattern mismatch: $NORMAL_BASENAME" >&2
  exit 1
fi

# Clean up generated files to avoid repo pollution
rm -f "$CREATED_META_PATH" "$CREATED_NORMAL_PATH"

echo "[PASS] meta spec generation behavior validated"
