# AIエージェント主導 SDD テンプレート（Laravel 初期対応）
## このテンプレートでできること
2. AIエージェントが SDD フロー（仕様 → 計画 → テスト → 実装 → 検証）に沿って作業を推進します。
4. 計画（plan）はエージェントが作成し、ユーザー承認ゲートで確定します。
7. テストの実行はエージェントが実行します（ローカルまたは CI）。

## ディレクトリ構成

- `specs/` 仕様書（ドラフト/承認済）
- `plans/` 実装計画（ドラフト/承認済）
- `tests/` テスト（ユニット/結合/シナリオなど）
- `scripts/` 初期化・生成・検証用スクリプト
- `templates/` 仕様・計画・テストのテンプレート
- `docs/` SDD フローや運用ドキュメント
- `.github/` ワークフロー・Issue/PR テンプレート・エージェント指示
前提: Linux + bash。Docker を推奨（Composer/PHP をローカルに入れなくても初期化可能）。

1) スタック設定を確認/更新
- `sdd.config.json` で `docker.enabled=true`（既定）。
- `make init` を実行すると composer コンテナ経由で Laravel + Sail をセットアップ。
- その後 `make up` でコンテナ起動、`make artisan CMD='migrate'` 等で操作。

3) SDD フロー

- 仕様作成: エージェントに「タイトル・概要」を伝えると `templates/spec.md` を基に `specs/` に草案を生成します。承認後、`approved` 印をつけます。
- 計画作成: 仕様に基づき `templates/plan.md` を基に `plans/` に草案を生成。承認後に確定。
- テスト作成: 計画に基づき `templates/test.md` を基に `tests/` に作成。
- 実装: テストを先に落とし、実装でグリーンにします。
- 検証: `scripts/test.sh` もしくは `make test-docker`、CI を使って検証。

<<<<<<< HEAD
 
=======
### メタ変更（テンプレート自身の改善）
- テンプレート（ドキュメント/Make/スクリプト/PRテンプレ等）の改善も SDD を厳守。
- 仕様起票はコマンドで行います:
	- `make spec TITLE='meta: <仕様の内容>'`
- 生成されるSpecファイル名: `specs/meta-<slug>-<stamp>.md`（例: `specs/meta-rule-update-20250101-120000.md`）。
	- ただし、slug が `meta` のみになるケースは冗長回避のため `specs/meta-<stamp>.md` に縮約。
>>>>>>> dd8d81c (meta: テンプレート改善もSDD遵守に統一\n\n- gen.sh: meta: タイトルのspecは meta-<slug>-<stamp>.md（slug=metaのときは meta-<stamp>.md に縮約）\n- tests: meta_spec_generation.sh 追加（固定名）\n- docs: README / docs/sdd-flow にメタ命名ルールとレガシー方針を追記\n- PR: .github/pull_request_template.md にメタ変更チェックリスト追加\n\nRefs: specs/20251113-025417-meta-sdd.md, plans/20251113-030953-meta-sdd.md)
- 旧形式（`meta=`）で作成済みのSpecは履歴保持のためリネーム不要。今後は `meta:` を使用。

## GitHub CI（条件付き）

Laravel プロジェクト（composer.json）が存在する場合のみ PHPUnit を実行する CI を提供します。初期化前はスキップされます。

## エージェント指示

`.github/copilot-instructions.md` にエージェントの振る舞いと承認ゲートに関するガイドラインがあります。エージェントは仕様と計画についてユーザー承認を必須とします。

## 注意

- Docker 有効時はホストに Composer/PHP 不要（composer:2 イメージ使用）。
- ネットワークや Docker が未設定の場合、初期化は失敗します。エラー内容に従ってセットアップしてください。
- 他スタック対応は `sdd.config.json` / `scripts/` を拡張してください。

## Docker コマンド速習

- 初期化: `make init`
- コンテナ起動/停止: `make up` / `make down`
- ログ/状態: `make logs` / `make ps`
- Artisan 実行: `make artisan CMD='migrate'`
- コンテナ内テスト: `make test-docker`

## ライセンス

MIT
