#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
TYPE="${1:-}"
TITLE="${2:-}"

if [[ -z "${TYPE}" || -z "${TITLE}" ]]; then
  echo "Usage: scripts/gen.sh <spec|plan|test> <title>" >&2
  exit 2
fi

case "$TYPE" in
  spec|plan|test) ;;
  *) echo "Unknown type: $TYPE" >&2; exit 2;;
esac

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g'
}

STAMP="$(date +%Y%m%d-%H%M%S)"
SLUG_RAW="$TITLE"
SLUG="$(slugify "$SLUG_RAW")"
TEMPLATE="$ROOT_DIR/templates/$TYPE.md"
TARGET_DIR="$ROOT_DIR/${TYPE}s"

# meta spec 特別命名: TITLEが'meta:'で始まり TYPE=spec のとき meta-<SLUG>-<STAMP>.md
if [[ "$TYPE" == "spec" && "$TITLE" == meta:* ]]; then
  # 先頭の 'meta:' を slug 生成時には含めているので、SLUGは "meta-..." になる可能性がある。
  # 意図はファイル名先頭に必ず 'meta-' を付与し、その後に slug と stamp。
  # slug に meta- が重複するなら一度除去。
  CLEAN_SLUG="$SLUG"
  if [[ "$CLEAN_SLUG" == meta-* ]]; then
    CLEAN_SLUG="${CLEAN_SLUG#meta-}"
  fi
  # 非ASCIIのみのタイトルの場合、slugが空になる可能性があるためフォールバック
  if [[ -z "$CLEAN_SLUG" ]]; then
    CLEAN_SLUG="meta"
  fi
  # slug が 'meta' のみの場合は冗長な meta-meta を避けて meta-<STAMP>.md に縮約
  if [[ "$CLEAN_SLUG" == "meta" ]]; then
    TARGET_FILE="$TARGET_DIR/meta-${STAMP}.md"
  else
    TARGET_FILE="$TARGET_DIR/meta-${CLEAN_SLUG}-${STAMP}.md"
  fi
else
  # 通常spec/plan/testは従来形式: <STAMP>-<SLUG>.md。ただし slug が空なら fallback
  if [[ -z "$SLUG" ]]; then
    SLUG="spec"
  fi
  TARGET_FILE="$TARGET_DIR/${STAMP}-${SLUG}.md"
fi

mkdir -p "$TARGET_DIR"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Template not found: $TEMPLATE" >&2
  exit 1
fi

sed -e "s/<TITLE>/$(printf '%s' "$TITLE" | sed 's%/%\\/%g')/g" \
    "$TEMPLATE" > "$TARGET_FILE"

printf "Created: %s\n" "$TARGET_FILE"
