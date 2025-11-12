#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

php_rc=0

echo "=== PHPUnit ==="
if [[ -f "$ROOT_DIR/composer.json" ]]; then
  if [[ -x "$ROOT_DIR/vendor/bin/phpunit" ]]; then
    (cd "$ROOT_DIR" && vendor/bin/phpunit) || php_rc=$?
  else
    if command -v composer >/dev/null 2>&1; then
      # try composer test, fallback to install + phpunit
      set +e
      (cd "$ROOT_DIR" && composer test)
      php_rc=$?
      if [[ $php_rc -ne 0 ]]; then
        (cd "$ROOT_DIR" && composer install && vendor/bin/phpunit)
        php_rc=$?
      fi
      set -e
    else
      echo "composer が見つからないため PHP テストを実行できません" >&2
      php_rc=127
    fi
  fi
else
  # Laravel サブディレクトリでの実行にも対応（最初に見つかった一つを実行）
  found=0
  for d in "$ROOT_DIR"/*; do
    if [[ -f "$d/composer.json" && -x "$d/vendor/bin/phpunit" ]]; then
      (cd "$d" && vendor/bin/phpunit) || php_rc=$?
      found=1
      break
    fi
  done
  if [[ $found -eq 0 ]]; then
    echo "PHPUnit 対象が見つかりません（composer.json がありません）" >&2
  fi
fi

echo "=== Shell ==="
shell_rc=0
failures=()
if [[ -d "$ROOT_DIR/tests" ]]; then
  # shellcheck disable=SC2207
  mapfile -t shell_tests < <(find "$ROOT_DIR/tests" -type f -name "*.sh" | sort)
  if [[ ${#shell_tests[@]} -eq 0 ]]; then
    echo "Shell テストが見つかりません (tests/*.sh)"
  else
    for t in "${shell_tests[@]}"; do
      if [[ ! -x "$t" ]]; then
        echo "[WARN] 非実行権限のためスキップ: $t"
        continue
      fi
      echo "[RUN ] $t"
      set +e
      bash "$t"
      rc=$?
      set -e
      if [[ $rc -ne 0 ]]; then
        echo "[FAIL] $t (rc=$rc)"
        failures+=("$t")
      else
        echo "[ OK ] $t"
      fi
    done
    if [[ ${#failures[@]} -gt 0 ]]; then
      shell_rc=1
    fi
  fi
else
  echo "tests ディレクトリが存在しません"
fi

echo "=== Summary ==="
echo "PHPUnit rc: $php_rc"
if [[ ${#failures[@]} -gt 0 ]]; then
  echo "Shell failed: ${#failures[@]} 件"
  for f in "${failures[@]}"; do echo " - $f"; done
else
  echo "Shell: OK"
fi

if [[ $php_rc -ne 0 || $shell_rc -ne 0 ]]; then
  exit 1
fi
exit 0
