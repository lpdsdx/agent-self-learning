#!/usr/bin/env bash
set -euo pipefail

# 重建学习索引（兼容 macOS bash 3.x）
# 环境检测
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/detect_env.sh" ]]; then
  LEARNING_DIR="${LEARNING_DIR:-$(bash "$SCRIPT_DIR/detect_env.sh" learning-dir)}"
else
  LEARNING_DIR="${LEARNING_DIR:-.learnings}"
fi

mkdir -p "$LEARNING_DIR"

# 如果没有学习记录，创建空索引
if [[ ! -d "$LEARNING_DIR/learnings" ]] || [[ -z "$(ls -A "$LEARNING_DIR/learnings" 2>/dev/null)" ]]; then
  cat > "$LEARNING_DIR/index.json" <<'EOF'
{
  "version": "1.0.0",
  "lastUpdated": "",
  "totalCount": 0,
  "byType": {},
  "byPriority": {},
  "learnings": []
}
EOF
  echo "索引已重建（无学习记录）"
  exit 0
fi

# 统计变量
TOTAL=0
TEMP_LEARNINGS=$(mktemp)
TEMP_TYPES=$(mktemp)
TEMP_PRIORITIES=$(mktemp)

# 遍历所有学习记录
for file in "$LEARNING_DIR/learnings"/*.json; do
  if [[ -f "$file" ]]; then
    TOTAL=$((TOTAL + 1))
    
    # 提取类型和优先级用于统计
    jq -r '.type' "$file" >> "$TEMP_TYPES"
    jq -r '.priority' "$file" >> "$TEMP_PRIORITIES"
    
    # 添加到临时文件
    jq -c "{id, type, priority, confidence, content, createdAt, file: \"$(basename "$file")\"}" "$file" >> "$TEMP_LEARNINGS"
  fi
done

# 统计类型
TYPE_JSON=$(sort "$TEMP_TYPES" | uniq -c | awk '{print "\"" $2 "\":" $1}' | paste -sd ',' - | sed 's/^/{/' | sed 's/$/}/')
if [[ -z "$TYPE_JSON" ]]; then
  TYPE_JSON="{}"
fi

# 统计优先级
PRIORITY_JSON=$(sort "$TEMP_PRIORITIES" | uniq -c | awk '{print "\"" $2 "\":" $1}' | paste -sd ',' - | sed 's/^/{/' | sed 's/$/}/')
if [[ -z "$PRIORITY_JSON" ]]; then
  PRIORITY_JSON="{}"
fi

# 读取所有学习记录到数组
LEARNINGS_ARRAY="["
FIRST=true
while IFS= read -r line; do
  if [[ "$FIRST" == "true" ]]; then
    FIRST=false
  else
    LEARNINGS_ARRAY+=","
  fi
  LEARNINGS_ARRAY+="$line"
done < "$TEMP_LEARNINGS"
LEARNINGS_ARRAY+="]"

# 生成最终索引
cat > "$LEARNING_DIR/index.json" <<EOF
{
  "version": "1.0.0",
  "lastUpdated": "$(date +"%Y-%m-%dT%H:%M:%S%z")",
  "totalCount": $TOTAL,
  "byType": $TYPE_JSON,
  "byPriority": $PRIORITY_JSON,
  "learnings": $LEARNINGS_ARRAY
}
EOF

# 清理临时文件
rm -f "$TEMP_LEARNINGS" "$TEMP_TYPES" "$TEMP_PRIORITIES"

echo "索引已重建: $TOTAL 条学习记录"
