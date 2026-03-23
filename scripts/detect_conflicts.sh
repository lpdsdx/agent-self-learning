#!/usr/bin/env bash
set -euo pipefail

# 冲突检测（简化版，兼容 macOS）
# 环境检测
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/detect_env.sh" ]]; then
  LEARNING_DIR="${LEARNING_DIR:-$(bash "$SCRIPT_DIR/detect_env.sh" learning-dir)}"
else
  LEARNING_DIR="${LEARNING_DIR:-.learnings}"
fi

if [[ ! -d "$LEARNING_DIR/learnings" ]]; then
  echo "未找到学习记录"
  exit 0
fi

echo "执行冲突检测"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CONFLICTS=0

# 简单的相似度检测：比较所有文件对
FILES=("$LEARNING_DIR/learnings"/*.json)
for ((i=0; i<${#FILES[@]}; i++)); do
  for ((j=i+1; j<${#FILES[@]}; j++)); do
    file1="${FILES[$i]}"
    file2="${FILES[$j]}"
    
    if [[ -f "$file1" ]] && [[ -f "$file2" ]]; then
      CONTENT1=$(jq -r '.content' "$file1" | tr '[:upper:]' '[:lower:]')
      CONTENT2=$(jq -r '.content' "$file2" | tr '[:upper:]' '[:lower:]')
      
      # 提取前3个词作为关键词
      KEY1=$(echo "$CONTENT1" | awk '{print $1,$2,$3}')
      KEY2=$(echo "$CONTENT2" | awk '{print $1,$2,$3}')
      
      # 如果关键词相似，报告冲突
      if [[ "$KEY1" == "$KEY2" ]] && [[ -n "$KEY1" ]]; then
        CONF1=$(jq -r '.confidence' "$file1")
        CONF2=$(jq -r '.confidence' "$file2")
        
        echo ""
        echo "⚠️  潜在冲突"
        echo "文件1: $(basename "$file1") (置信度: $CONF1)"
        echo "内容: $CONTENT1"
        echo ""
        echo "文件2: $(basename "$file2") (置信度: $CONF2)"
        echo "内容: $CONTENT2"
        echo ""
        
        CONFLICTS=$((CONFLICTS + 1))
      fi
    fi
  done
done

if [[ $CONFLICTS -eq 0 ]]; then
  echo "✓ 未发现冲突"
else
  echo "发现 $CONFLICTS 个潜在冲突，请人工审查"
fi
