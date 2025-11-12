#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
CONFIG_FILE="$ROOT_DIR/sdd.config.json"

log() { printf "[init] %s\n" "$*"; }
warn() { printf "[init:warn] %s\n" "$*" 1>&2; }
err()  { printf "[init:err] %s\n" "$*" 1>&2; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || return 1
}

parse_json() {
  local key="$1"
  if require_cmd jq; then
    jq -r "$key // empty" "$CONFIG_FILE" 2>/dev/null || true
  elif require_cmd python3; then
    python3 - <<PY 2>/dev/null || true
import json,sys
with open("$CONFIG_FILE") as f:
    cfg=json.load(f)
# crude json-path like: .a.b -> ['a']['b']
path = "$key".lstrip('.')
obj = cfg
try:
    for p in path.split('.'):
        if '[' in p:
            name, rest = p.split('[',1)
            if name:
                obj = obj.get(name)
            idx = int(rest.rstrip(']'))
            obj = obj[idx]
        else:
            obj = obj.get(p)
    if obj is None:
        pass
    elif isinstance(obj, (dict, list)):
        print("")
    else:
        print(obj)
except Exception:
    pass
PY
  else
    # Fallback: unsupported parser
    echo ""
  fi
}

if [[ ! -f "$CONFIG_FILE" ]]; then
  err "sdd.config.json が見つかりません: $CONFIG_FILE"
  exit 1
fi

STACK="$(parse_json '.stack')"
STACK="${STACK:-laravel}"

log "stack = $STACK"

case "$STACK" in
  laravel)
    "$ROOT_DIR/scripts/setup-laravel.sh"
    ;;
  *)
    warn "未対応のスタックです: $STACK"
    warn "scripts/ 以下に <stack>-setup スクリプトを追加してください。"
    ;;

esac

log "初期化完了（必要な場合は次に 'scripts/test.sh' で検証）。"
