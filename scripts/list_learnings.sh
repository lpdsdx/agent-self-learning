#!/usr/bin/env bash
set -euo pipefail

# 列出学习记录（多 IDE 兼容，跨平台）

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

# 参数
TYPE=""
PRIORITY=""
TAGS=""
LIMIT=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) TYPE="$2"; shift 2 ;;
    --priority) PRIORITY="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --limit) LIMIT="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

if [[ ! -f "$LEARNING_DIR/index.json" ]]; then
  echo "未找到索引文件，正在重建..."
  bash "$SCRIPT_DIR/rebuild_index.sh"
fi

# 读取索引
INDEX=$(cat "$LEARNING_DIR/index.json")

# 过滤（使用 --arg 防止注入）
FILTERED="$INDEX"
if [[ -n "$TYPE" ]]; then
  FILTERED=$(echo "$FILTERED" | jq --arg t "$TYPE" '.learnings | map(select(.type == $t))')
else
  FILTERED=$(echo "$FILTERED" | jq '.learnings')
fi

if [[ -n "$PRIORITY" ]]; then
  FILTERED=$(echo "$FILTERED" | jq --arg p "$PRIORITY" 'map(select(.priority == $p))')
fi

if [[ -n "$TAGS" ]]; then
  FILTERED=$(echo "$FILTERED" | jq --arg tg "$TAGS" 'map(select(.tags | index($tg)))')
fi

# 限制数量
if [[ -n "$LIMIT" ]]; then
  FILTERED=$(echo "$FILTERED" | jq --argjson n "$LIMIT" '.[:$n]')
fi

# 输出：从实际文件读取 content 和 confidence
echo "$FILTERED" | jq -r '.[].file // empty' | while IFS= read -r file; do
  filepath="$LEARNING_DIR/learnings/$file"
  if [[ -f "$filepath" ]]; then
    jq -r '"[\(.priority // "?" | ascii_upcase)] \(.type // "?") (置信度: \(.confidence // "?")) - \(.content // "?")"' "$filepath"
  fi
done
