#!/usr/bin/env bash
set -euo pipefail

# 会话开始初始化（跨平台）

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

mkdir -p "$LEARNING_DIR/learnings"

# 如果索引不存在，创建
if [[ ! -f "$LEARNING_DIR/index.json" ]]; then
  bash "$SCRIPT_DIR/rebuild_index.sh" >/dev/null 2>&1
fi

# 输出学习知识库摘要
if [[ -f "$LEARNING_DIR/index.json" ]]; then
  TOTAL=$(jq -r '.totalCount // 0' "$LEARNING_DIR/index.json")
  TOTAL="${TOTAL:-0}"

  if [[ "$TOTAL" -gt 0 ]] 2>/dev/null; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📚 学习知识库已加载 ($TOTAL 条记录)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 输出高优先级学习记录
    echo "## 高优先级学习记录"
    echo ""
    jq -r '.learnings[] | select(.priority == "critical" or .priority == "high") | "- [\(.priority | ascii_upcase)] \(.type): \(.content)"' "$LEARNING_DIR/index.json" | head -10
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  fi
fi
