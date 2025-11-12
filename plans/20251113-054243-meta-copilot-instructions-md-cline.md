# Plan: meta: copilot-instructions.mdの内容をCline用に再構築する

## 方針
- アーキテクチャ/設計方針:
    - `copilot-instructions.md`の内容を「人格（Personality）」と「SDDワークフロー（SDD Workflow Guardrails）」の2つのセクションに分割する。
    - それぞれを`.clinerules/personality.md`と`.clinerules/sdd-workflow.md`としてMarkdown形式で保存する。
    - Clineがこれらのファイルをカスタム指示として読み込めるように、ファイルパスを考慮した記述にする。
    - 元の`copilot-instructions.md`は削除せず、必要に応じて参照できるように残す。
- データモデル/スキーマ: N/A
- インターフェース/API: N/A

## タスク分解（SDD順序）
1) 仕様確定（承認）
2) テスト設計（受け入れ基準に対応）
3) 実装（テストをグリーンに）
4) リファクタリングと観測性の追加
5) セキュリティ/パフォーマンス確認

## 具体タスク
| ID | 種別(SPEC/TEST/CODE/OPS) | 内容 | 完了条件 |
|----|--------------------------|------|----------|
| T-1 | CODE | `.clinerules/`ディレクトリを作成する。 | `.clinerules/`ディレクトリが存在する。 |
| T-2 | CODE | `copilot-instructions.md`の「Personality」セクションを抽出し、`.clinerules/personality.md`として保存する。 | `personality.md`が作成され、内容が正しい。 |
| T-3 | CODE | `copilot-instructions.md`の「SDD Workflow Guardrails」セクションを抽出し、`.clinerules/sdd-workflow.md`として保存する。 | `sdd-workflow.md`が作成され、内容が正しい。 |
| T-4 | TEST | 作成された`personality.md`と`sdd-workflow.md`の内容が、元の`copilot-instructions.md`から正しく分割・抽出されていることを確認する。 | 各ファイルの受け入れ基準が満たされている。 |
| T-5 | OPS | Clineのカスタム指示として、新しく作成したファイルを読み込む設定をユーザーに案内する。 | ユーザーが設定方法を理解し、実行できる。 |

## スケジュール
- 着手: 2025-11-13
- 完了予定: 2025-11-13

## リスク/ブロッカー
- Clineがカスタム指示を完全に理解し、意図通りに動作しない可能性がある。

## 承認
- Plan 作成者: Cline
- レビュー: <REVIEWER>
- 承認日時: <APPROVED_AT>
- ステータス: DRAFT
