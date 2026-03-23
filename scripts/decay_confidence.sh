#!/usr/bin/env bash
set -euo pipefail

# 置信度衰减
# 环境检测
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/detect_env.sh" ]]; then
  LEARNING_DIR="${LEARNING_DIR:-$(bash "$SCRIPT_DIR/detect_env.sh" learning-dir)}"
else
  LEARNING_DIR="${LEARNING_DIR:-.learnings}"
fi
DAYS="${1:-30}"
DECAY_RATE=0.05

if [[ ! -d "$LEARNING_DIR/learnings" ]]; then
  echo "未找到学习记录"
  exit 0
fi

CURRENT_TIME=$(date +%s)
THRESHOLD=$((DAYS * 86400))
UPDATED=0

echo "执行置信度衰减（超过 $DAYS 天未使用）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for file in "$LEARNING_DIR/learnings"/*.json; do
  if [[ -f "$file" ]]; then
    LAST_VERIFIED=$(jq -r '.lastVerified' "$file")
    LAST_TIME=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$LAST_VERIFIED" +%s 2>/dev/null || echo "0")
    
    if [[ $LAST_TIME -gt 0 ]]; then
      DIFF=$((CURRENT_TIME - LAST_TIME))
      
      if [[ $DIFF -gt $THRESHOLD ]]; then
        CONFIDENCE=$(jq -r '.confidence' "$file")
        NEW_CONFIDENCE=$(echo "$CONFIDENCE - $DECAY_RATE" | bc)
        
        # 确保置信度不低于 0.50
        if (( $(echo "$NEW_CONFIDENCE < 0.50" | bc -l) )); then
          NEW_CONFIDENCE="0.50"
        fi
        
        # 更新文件
        jq ".confidence = $NEW_CONFIDENCE" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
        
        CONTENT=$(jq -r '.content' "$file")
        echo "✓ $(basename "$file"): $CONFIDENCE → $NEW_CONFIDENCE"
        echo "  内容: $CONTENT"
        UPDATED=$((UPDATED + 1))
      fi
    fi
  fi
done

if [[ $UPDATED -eq 0 ]]; then
  echo "无需衰减的记录"
else
  echo ""
  echo "已更新 $UPDATED 条记录"
  bash "$(dirname "$0")/rebuild_index.sh" >/dev/null 2>&1
fi
