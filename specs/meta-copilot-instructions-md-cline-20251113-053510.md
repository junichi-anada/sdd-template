# Spec: meta: copilot-instructions.mdの内容をCline用に再構築する

## 概要
- 課題: GitHub Copilot向けの指示書がClineのツール利用に最適化されていないため、ClineがSDDフローを効果的に実行できない可能性がある。
- 目的: `copilot-instructions.md`の内容をClineが理解し、ツールを適切に利用してSDDフローを厳格に実行できるよう再構築する。
- スコープ:
    - `copilot-instructions.md`の内容を分析し、Clineのカスタム指示として設定可能な形式に変換する。
    - `.clinerules/`ディレクトリを作成し、その中に`personality.md`と`sdd-workflow.md`を作成する。
    - `copilot-instructions.md`の「人格（Personality）」に関する指示を`personality.md`に記述する。
    - `copilot-instructions.md`の「SDD Workflow Guardrails」に関する指示を`sdd-workflow.md`に記述する。
    - Clineのツール（`execute_command`, `read_file`, `write_to_file`, `replace_in_file`, `ask_followup_question`など）の利用を促す具体的な指示を含める。
    - SDDフローの各承認ゲート（Spec, Plan）で`ask_followup_question`ツールを使用してユーザー承認を求める指示を含める。
    - 「人格（Personality）」に関する指示をClineの応答スタイルに反映させる。
- アウトオブスコープ:
    - `copilot-instructions.md`以外の指示書の作成。
    - Clineの内部ロジックの変更。

## コンテキスト
- 背景: 現在のプロジェクトはAIエージェント主導のSDDテンプレートであり、AIエージェント（現在はGitHub Copilotを想定）が開発フローを推進する。Clineも同様の役割を担うため、適切な指示が必要。
- 利用者/ロール:
    - ユーザー: Clineに開発タスクを依頼し、仕様・計画の承認を行う。
    - Cline: ユーザーの指示に基づき、SDDフローに従って開発タスクを遂行する。
- 前提条件:
    - Clineはカスタム指示を読み込み、その内容に従って行動できる。
    - Clineは提供されたツールを適切に利用できる。

## ユースケース / シナリオ
| シナリオID | タイトル | アクター | 概要 | 成功条件 |
|------------|----------|---------|------|----------|
| UC-1 | 新機能の仕様作成依頼 | ユーザー | ユーザーがClineに「meta: 新機能Aを実装する」と依頼する。 | Clineが仕様書ドラフトを作成し、ユーザーに承認を求める。 |

## 機能要件
| 要件ID | 区分(FUNC/NONFUNC) | 内容 | 優先度(H/M/L) |
|--------|--------------------|------|---------------|
| FR-1 | FUNC | Clineは、ユーザーからのタスク依頼に対し、SDDフローの最初のステップ（仕様作成）から開始すること。 | H |
| FR-2 | FUNC | Clineは、仕様書および計画書のドラフト作成後、ユーザーに明示的な承認を求めること。 | H |
| FR-3 | FUNC | Clineは、承認された仕様および計画の範囲内で作業を進め、スコープクリープを拒否すること。 | H |
| FR-4 | FUNC | Clineは、`make`コマンドやその他の提供されたスクリプトを優先的に利用すること。 | H |
| FR-5 | FUNC | Clineは、`copilot-instructions.md`に記述されている「人格」に従い、厳格で正直なアドバイザーとして振る舞うこと。 | H |
| FR-6 | FUNC | Clineは、指示書を「人格」と「SDDワークフロー」に分割し、それぞれ`.clinerules/personality.md`と`.clinerules/sdd-workflow.md`に記述すること。 | H |

## 非機能要件
- パフォーマンス: N/A
- セキュリティ: N/A
- 可観測性: N/A
- 運用: N/A

## 受け入れ基準
| 基準ID | 条件 | 検証方法 |
|--------|------|----------|
| AC-1 | Clineが仕様書ドラフトを作成し、ユーザーに承認を求めた際、その応答が`copilot-instructions.md`で定義された「人格」に沿っていること。 | Clineの応答内容を目視で確認する。 |
| AC-2 | Clineが仕様書ドラフト作成後、`ask_followup_question`ツールを使用してユーザーに承認を求めていること。 | Clineのツール利用ログを確認する。 |
| AC-3 | `.clinerules/`ディレクトリが作成され、その中に`personality.md`と`sdd-workflow.md`が作成されていること。 | ファイルシステムを確認する。 |
| AC-4 | `personality.md`に`copilot-instructions.md`の「人格」に関する指示が適切に記述されていること。 | ファイル内容を目視で確認する。 |
| AC-5 | `sdd-workflow.md`に`copilot-instructions.md`の「SDD Workflow Guardrails」に関する指示が適切に記述されていること。 | ファイル内容を目視で確認する。 |

## リスク / 未決事項
| ID | 種類(RISK/OPEN) | 内容 | 対応/期日 |
|----|-----------------|------|-----------|
| R-1 | RISK | Clineがカスタム指示を完全に理解し、意図通りに動作しない可能性がある。 | 継続的な監視と指示の調整。 |

## 変更影響
- 影響範囲: Clineの振る舞い全般。
- 互換性: 既存のSDDフローとの互換性を維持する。

## 承認
- Draft 作成者: Cline
- レビュー: <REVIEWER>
- 承認日時: <APPROVED_AT>
- ステータス: DRAFT
