#!/usr/bin/env bash
set -euo pipefail

# 会话开始初始化
LEARNING_DIR="${LEARNING_DIR:-.learnings}"

mkdir -p "$LEARNING_DIR/learnings"

# 如果索引不存在，创建
if [[ ! -f "$LEARNING_DIR/index.json" ]]; then
  bash "$(dirname "$0")/rebuild_index.sh" >/dev/null 2>&1
fi

# 输出学习知识库摘要（供 Claude 读取）
if [[ -f "$LEARNING_DIR/index.json" ]]; then
  TOTAL=$(jq -r '.totalCount' "$LEARNING_DIR/index.json")
  
  if [[ "$TOTAL" -gt 0 ]]; then
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
