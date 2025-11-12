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
SLUG="$(slugify "$TITLE")"
TEMPLATE="$ROOT_DIR/templates/$TYPE.md"
TARGET_DIR="$ROOT_DIR/${TYPE}s"
TARGET_FILE="$TARGET_DIR/${STAMP}-${SLUG}.md"

mkdir -p "$TARGET_DIR"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Template not found: $TEMPLATE" >&2
  exit 1
fi

sed -e "s/<TITLE>/$(printf '%s' "$TITLE" | sed 's%/%\\/%g')/g" \
    "$TEMPLATE" > "$TARGET_FILE"

printf "Created: %s\n" "$TARGET_FILE"
