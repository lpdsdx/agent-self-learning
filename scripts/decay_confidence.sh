#!/usr/bin/env bash
set -euo pipefail

# 置信度衰减（跨平台: macOS / Linux / Windows Git Bash）

# 依赖检查
for cmd in jq; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "错误: 需要 $cmd，请先安装" >&2
    exit 1
  fi
done

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

# 跨平台日期解析 (ISO 8601 -> epoch seconds)
parse_date() {
  local datestr="$1"
  # 尝试 GNU date (Linux)
  date -d "$datestr" +%s 2>/dev/null && return 0
  # 尝试 BSD date (macOS)
  # 先尝试带时区的格式，再尝试 UTC 格式
  date -j -f "%Y-%m-%dT%H:%M:%S%z" "$datestr" +%s 2>/dev/null && return 0
  date -j -f "%Y-%m-%dT%H:%M:%SZ" "$datestr" +%s 2>/dev/null && return 0
  # 回退: 用 python3 (macOS/Linux/Windows 通常都有)
  python3 -c "from datetime import datetime,timezone; print(int(datetime.fromisoformat('$datestr'.replace('Z','+00:00')).timestamp()))" 2>/dev/null && return 0
  echo "0"
}

CURRENT_TIME=$(date +%s)
THRESHOLD=$((DAYS * 86400))
UPDATED=0

echo "执行置信度衰减（超过 $DAYS 天未使用）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for file in "$LEARNING_DIR/learnings"/*.json; do
  if [[ -f "$file" ]]; then
    LAST_VERIFIED=$(jq -r '.lastVerified' "$file")
    LAST_TIME=$(parse_date "$LAST_VERIFIED")

    if [[ $LAST_TIME -gt 0 ]]; then
      DIFF=$((CURRENT_TIME - LAST_TIME))

      if [[ $DIFF -gt $THRESHOLD ]]; then
        CONFIDENCE=$(jq -r '.confidence' "$file")
        # 用 awk 代替 bc 做浮点运算（更好的跨平台兼容性）
        NEW_CONFIDENCE=$(awk "BEGIN {printf \"%.2f\", $CONFIDENCE - $DECAY_RATE}")

        # 确保置信度不低于 0.50
        if awk "BEGIN {exit !($NEW_CONFIDENCE < 0.50)}"; then
          NEW_CONFIDENCE="0.50"
        fi

        # 更新文件
        jq ".confidence = $NEW_CONFIDENCE" "$file" > "$file.tmp" && mv "$file.tmp" "$file"

        CONTENT=$(jq -r '.content' "$file")
        echo "  $(basename "$file"): $CONFIDENCE -> $NEW_CONFIDENCE"
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
