#!/usr/bin/env bash
set -euo pipefail

# 搜索学习记录（多 IDE 兼容，跨平台）

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

QUERY="${1:-}"

if [[ -z "$QUERY" ]]; then
  echo "用法: search_learnings.sh <关键词>"
  exit 1
fi

if [[ ! -d "$LEARNING_DIR/learnings" ]]; then
  echo "未找到学习记录"
  exit 0
fi

echo "搜索结果: \"$QUERY\""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for file in "$LEARNING_DIR/learnings"/*.json; do
  if [[ -f "$file" ]]; then
    # 使用 -F 固定字符串匹配，避免正则元字符问题
    if grep -qiF "$QUERY" "$file"; then
      TYPE=$(jq -r '.type' "$file")
      PRIORITY=$(jq -r '.priority' "$file")
      CONTENT=$(jq -r '.content' "$file")
      CONFIDENCE=$(jq -r '.confidence' "$file")
      CREATED=$(jq -r '.createdAt' "$file")

      echo ""
      echo "[$PRIORITY] $TYPE (置信度: $CONFIDENCE)"
      echo "内容: $CONTENT"
      echo "创建: $CREATED"
      echo "文件: $(basename "$file")"
    fi
  fi
done
