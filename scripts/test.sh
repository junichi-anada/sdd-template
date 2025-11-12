#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

run_phpunit() {
  if [[ -x "$1" ]]; then
    "$1"
    return $?
  fi
  return 127
}

if [[ -f "$ROOT_DIR/composer.json" ]]; then
  if [[ -x "$ROOT_DIR/vendor/bin/phpunit" ]]; then
    "$ROOT_DIR/vendor/bin/phpunit"
    exit $?
  fi
  if command -v composer >/dev/null 2>&1; then
    (cd "$ROOT_DIR" && composer test) || (cd "$ROOT_DIR" && composer install && vendor/bin/phpunit)
    exit $?
  fi
  echo "composer が見つからないためテストを実行できません" >&2
  exit 127
fi

# Laravel サブディレクトリでの実行にも対応
for d in "$ROOT_DIR"/*; do
  if [[ -f "$d/composer.json" && -x "$d/vendor/bin/phpunit" ]]; then
    (cd "$d" && vendor/bin/phpunit)
    exit $?
  fi
done

echo "PHPUnit 対象が見つかりません（composer.json がありません）" >&2
exit 0
