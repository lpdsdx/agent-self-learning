#!/usr/bin/env bash
set -euo pipefail

# 更新摘要文件（多 IDE 兼容，跨平台）

# 依赖检查
if ! command -v jq &>/dev/null; then
  echo "错误: 需要 jq，请先安装" >&2
  exit 1
fi
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/detect_env.sh" ]]; then
  LEARNING_DIR="${LEARNING_DIR:-$(bash "$SCRIPT_DIR/detect_env.sh" learning-dir)}"
else
  LEARNING_DIR="${LEARNING_DIR:-.learnings}"
fi

if [[ ! -f "$LEARNING_DIR/index.json" ]]; then
  exit 0
fi

INDEX=$(cat "$LEARNING_DIR/index.json")
TOTAL=$(echo "$INDEX" | jq -r '.totalCount')
LAST_UPDATED=$(echo "$INDEX" | jq -r '.lastUpdated')

cat > "$LEARNING_DIR/summary.md" << EOF
# 学习记录摘要

**最后更新**: $LAST_UPDATED
**总记录数**: $TOTAL

## 按类型统计

EOF

echo "$INDEX" | jq -r '.byType | to_entries[] | "- **\(.key)**: \(.value) 条"' >> "$LEARNING_DIR/summary.md"

cat >> "$LEARNING_DIR/summary.md" << EOF

## 按优先级统计

EOF

echo "$INDEX" | jq -r '.byPriority | to_entries[] | "- **\(.key)**: \(.value) 条"' >> "$LEARNING_DIR/summary.md"

cat >> "$LEARNING_DIR/summary.md" << EOF

## 最近学习记录

EOF

echo "$INDEX" | jq -r '.learnings[-10:] | reverse | .[] | "### [\(.priority | ascii_upcase)] \(.type)\n\n**置信度**: \(.confidence)  \n**创建时间**: \(.createdAt)  \n**内容**: \(.content)\n"' >> "$LEARNING_DIR/summary.md"

echo "摘要已更新"
