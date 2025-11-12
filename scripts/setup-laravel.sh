#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
CONFIG_FILE="$ROOT_DIR/sdd.config.json"
log() { printf "[laravel] %s\n" "$*"; }
warn() { printf "[laravel:warn] %s\n" "$*" 1>&2; }
err()  { printf "[laravel:err] %s\n" "$*" 1>&2; }

require_cmd() { command -v "$1" >/dev/null 2>&1; }

parse_json() {
  local key="$1"
  if require_cmd jq; then
    jq -r "$key // empty" "$CONFIG_FILE" 2>/dev/null || true
  else
    python3 - <<PY 2>/dev/null || true
import json,sys
with open("$CONFIG_FILE") as f: cfg=json.load(f)
path = "$key".lstrip('.')
obj = cfg
try:
    for p in path.split('.'):
        obj = obj.get(p)
    if isinstance(obj,(dict,list)):
        print("")
    elif obj is not None:
        print(obj)
except Exception: pass
PY
  fi
}

PROJECT_NAME="$(parse_json '.laravel.projectName')"
PROJECT_NAME="${PROJECT_NAME:-sdd-app}"
LARAVEL_VERSION="$(parse_json '.laravel.version')"
WITH_PEST="$(parse_json '.laravel.withPest')"

DOCKER_ENABLED="$(parse_json '.docker.enabled')"
SAIL_USE="$(parse_json '.docker.sail.use')"
SAIL_WITH_RAW="$(parse_json '.docker.sail.with')"
SAIL_PHP_VERSION="$(parse_json '.docker.sail.php')"
SAIL_WITH="mysql"
if [[ -n "$SAIL_WITH_RAW" ]]; then
  # Convert ["a","b"] or space-separated to comma list
  SAIl_TMP=$(printf '%s' "$SAIL_WITH_RAW" | tr -d '[]"' | tr ' ' ',')
  SAIL_WITH=${SAIl_TMP:-mysql}
fi

if [[ -d "$ROOT_DIR/$PROJECT_NAME" && -f "$ROOT_DIR/$PROJECT_NAME/composer.json" ]]; then
  log "既存の Laravel プロジェクトが存在します。スキップ。 ($PROJECT_NAME)"
  exit 0
fi

log "Laravel プロジェクトを作成します: $PROJECT_NAME (version: ${LARAVEL_VERSION:-latest})"

if [[ "$DOCKER_ENABLED" == "true" ]]; then
  if ! require_cmd docker; then
    err "docker が必要です。インストール後に再実行してください。"
    exit 1
  fi
  # Prefer docker compose v2 plugin; fallback to docker-compose
  if docker compose version >/dev/null 2>&1; then :; elif require_cmd docker-compose; then :; else
    err "docker compose (または docker-compose) が必要です。"
    exit 1
  fi

  # Use composer container to create project without host composer
  DOCKER_UID="$(id -u)"; DOCKER_GID="$(id -g)"
  CREATE_CMD=(docker run --rm -u "${DOCKER_UID}:${DOCKER_GID}" -v "$ROOT_DIR":/app -w /app composer:2 create-project laravel/laravel "$PROJECT_NAME")
  if [[ -n "$LARAVEL_VERSION" ]]; then
    CREATE_CMD+=("$LARAVEL_VERSION")
  fi
  "${CREATE_CMD[@]}"
  log "composer(create-project via Docker) 完了"

  pushd "$ROOT_DIR/$PROJECT_NAME" >/dev/null
  if [[ "$SAIL_USE" == "true" ]]; then
    # require sail
    docker run --rm -u "${DOCKER_UID}:${DOCKER_GID}" -v "$PWD":/app -w /app composer:2 require laravel/sail --dev
    # install sail with selected services
    PHP_IMG="laravelsail/php${SAIL_PHP_VERSION:-83}-composer:latest"
    docker run --rm -u "${DOCKER_UID}:${DOCKER_GID}" -v "$PWD":/var/www/html -w /var/www/html "$PHP_IMG" php artisan sail:install --with="${SAIL_WITH}"
    # boot containers
    bash vendor/bin/sail up -d
    # generate app key
    bash vendor/bin/sail artisan key:generate
    if [[ "$WITH_PEST" == "true" ]]; then
      bash vendor/bin/sail composer require pestphp/pest --dev || warn "Pest 追加に失敗"
      bash vendor/bin/sail artisan pest:install || warn "Pest インストールに失敗"
    fi
  else
    warn "docker.enabled=true だが sail.use=false のため、コンテナ起動は行いません。必要に応じて手動で compose を作成してください。"
  fi
  popd >/dev/null
else
  # Host composer fallback
  if ! require_cmd composer; then
    err "composer コマンドが見つかりません。Docker を有効化するか、Composer をインストールしてください。"
    exit 1
  fi
  CREATE_ARGS=(create-project laravel/laravel "$PROJECT_NAME")
  if [[ -n "$LARAVEL_VERSION" ]]; then
    CREATE_ARGS+=("$LARAVEL_VERSION")
  fi
  composer "${CREATE_ARGS[@]}"
  log "composer create-project 完了"

  if [[ "$WITH_PEST" == "true" ]]; then
    (cd "$ROOT_DIR/$PROJECT_NAME" && composer require pestphp/pest --dev && php artisan pest:install || warn "Pest 導入に失敗")
    log "Pest インストール試行完了"
  fi
fi

log "Laravel 初期セットアップ完了: $PROJECT_NAME"
