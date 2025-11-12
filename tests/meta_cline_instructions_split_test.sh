#!/bin/bash

# テスト対象のファイルパス
COPILOT_INSTRUCTIONS=".github/copilot-instructions.md"
CLINE_RULES_DIR=".clinerules"
PERSONALITY_FILE="${CLINE_RULES_DIR}/personality.md"
SDD_WORKFLOW_FILE="${CLINE_RULES_DIR}/sdd-workflow.md"

# テスト開始メッセージ
echo "--- Running Cline Instructions Split Test ---"

# 1. .clinerules ディレクトリが存在することを確認
if [ ! -d "$CLINE_RULES_DIR" ]; then
    echo "Error: Directory $CLINE_RULES_DIR does not exist."
    exit 1
fi
echo "Check: $CLINE_RULES_DIR directory exists."

# 2. personality.md ファイルが存在することを確認
if [ ! -f "$PERSONALITY_FILE" ]; then
    echo "Error: File $PERSONALITY_FILE does not exist."
    exit 1
fi
echo "Check: $PERSONALITY_FILE exists."

# 3. sdd-workflow.md ファイルが存在することを確認
if [ ! -f "$SDD_WORKFLOW_FILE" ]; then
    echo "Error: File $SDD_WORKFLOW_FILE does not exist."
    exit 1
fi
echo "Check: $SDD_WORKFLOW_FILE exists."

# 4. personality.md の内容が元のファイルから正しく抽出されていることを確認
#    元のファイルの "Personality" セクションの開始と終了を特定
PERSONALITY_START=$(grep -n "^# Personality" "$COPILOT_INSTRUCTIONS" | cut -d: -f1)
SDD_WORKFLOW_START=$(grep -n "^## SDD Workflow Guardrails (Repo-Specific)" "$COPILOT_INSTRUCTIONS" | cut -d: -f1)

if [ -z "$PERSONALITY_START" ] || [ -z "$SDD_WORKFLOW_START" ]; then
    echo "Error: Could not find 'Personality' or 'SDD Workflow Guardrails' sections in $COPILOT_INSTRUCTIONS."
    exit 1
fi

# Personalityセクションの期待される内容を抽出 (SDD Workflow Guardrailsの開始行の1つ前まで)
EXPECTED_PERSONALITY_CONTENT=$(sed -n "${PERSONALITY_START},$((${SDD_WORKFLOW_START}-1))p" "$COPILOT_INSTRUCTIONS")
ACTUAL_PERSONALITY_CONTENT=$(cat "$PERSONALITY_FILE")

# 行末の空白文字を削除して比較
if [ "$(echo "$EXPECTED_PERSONALITY_CONTENT" | sed 's/[[:space:]]*$//')" != "$(echo "$ACTUAL_PERSONALITY_CONTENT" | sed 's/[[:space:]]*$//')" ]; then
    echo "Error: Content of $PERSONALITY_FILE does not match expected Personality section."
    # diff -u <(echo "$EXPECTED_PERSONALITY_CONTENT") <(echo "$ACTUAL_PERSONALITY_CONTENT")
    exit 1
fi
echo "Check: $PERSONALITY_FILE content matches expected."

# 5. sdd-workflow.md の内容が元のファイルから正しく抽出されていることを確認
#    元のファイルの "SDD Workflow Guardrails" セクションの開始からファイルの最後まで
SDD_WORKFLOW_START=$(grep -n "^## SDD Workflow Guardrails (Repo-Specific)" "$COPILOT_INSTRUCTIONS" | cut -d: -f1)
FILE_END=$(wc -l < "$COPILOT_INSTRUCTIONS")

if [ -z "$SDD_WORKFLOW_START" ]; then
    echo "Error: Could not find 'SDD Workflow Guardrails' section in $COPILOT_INSTRUCTIONS."
    exit 1
fi

# SDD Workflow Guardrailsセクションの期待される内容を抽出 (ファイルの最後まで)
EXPECTED_SDD_WORKFLOW_CONTENT=$(sed -n "${SDD_WORKFLOW_START},${FILE_END}p" "$COPILOT_INSTRUCTIONS")
ACTUAL_SDD_WORKFLOW_CONTENT=$(cat "$SDD_WORKFLOW_FILE")

# 行末の空白文字を削除して比較
if [ "$(echo "$EXPECTED_SDD_WORKFLOW_CONTENT" | sed 's/[[:space:]]*$//')" != "$(echo "$ACTUAL_SDD_WORKFLOW_CONTENT" | sed 's/[[:space:]]*$//')" ]; then
    echo "Error: Content of $SDD_WORKFLOW_FILE does not match expected SDD Workflow Guardrails section."
    # diff -u <(echo "$EXPECTED_SDD_WORKFLOW_CONTENT") <(echo "$ACTUAL_SDD_WORKFLOW_CONTENT")
    exit 1
fi
echo "Check: $SDD_WORKFLOW_FILE content matches expected."

echo "--- All tests passed! ---"
exit 0
