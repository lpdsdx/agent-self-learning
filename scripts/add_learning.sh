#!/usr/bin/env bash
set -euo pipefail

# AI 智能体自学习系统 - 添加学习记录（多 IDE 兼容）
# 用法: add_learning.sh --type <type> --content <content> [--priority <priority>] [--tags <tags>]

# 环境检测
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/detect_env.sh" ]]; then
  LEARNING_DIR="${LEARNING_DIR:-$(bash "$SCRIPT_DIR/detect_env.sh" learning-dir)}"
else
  LEARNING_DIR="${LEARNING_DIR:-.learnings}"
fi

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S%z")
DATE_PREFIX=$(date +"%Y-%m-%d")

# 默认值
TYPE=""
CONTENT=""
CONTEXT=""
PRIORITY="medium"
TAGS=""
CONFIDENCE=""
SOURCE="manual"

# 解析参数
while [[ $# -gt 0 ]]; do
  case $1 in
    --type) TYPE="$2"; shift 2 ;;
    --content) CONTENT="$2"; shift 2 ;;
    --context) CONTEXT="$2"; shift 2 ;;
    --priority) PRIORITY="$2"; shift 2 ;;
    --tags) TAGS="$2"; shift 2 ;;
    --confidence) CONFIDENCE="$2"; shift 2 ;;
    --source) SOURCE="$2"; shift 2 ;;
    *)
      echo "未知参数: $1"
      exit 1
      ;;
  esac
done

# 验证必需参数
if [[ -z "$TYPE" ]] || [[ -z "$CONTENT" ]]; then
  echo "错误: --type 和 --content 是必需参数"
  echo "用法: add_learning.sh --type <type> --content <content> [options]"
  echo ""
  echo "类型: correction, remember, success_pattern, preference"
  echo "优先级: critical, high, medium"
  exit 1
fi

# 验证类型
if [[ ! "$TYPE" =~ ^(correction|remember|success_pattern|preference)$ ]]; then
  echo "错误: 无效的类型 '$TYPE'"
  echo "有效类型: correction, remember, success_pattern, preference"
  exit 1
fi

# 验证优先级
if [[ ! "$PRIORITY" =~ ^(critical|high|medium)$ ]]; then
  echo "错误: 无效的优先级 '$PRIORITY'"
  echo "有效优先级: critical, high, medium"
  exit 1
fi

# 自动计算置信度（如果未提供）
if [[ -z "$CONFIDENCE" ]]; then
  case "$TYPE" in
    correction)
      case "$PRIORITY" in
        critical) CONFIDENCE="0.90" ;;
        high) CONFIDENCE="0.85" ;;
        medium) CONFIDENCE="0.75" ;;
      esac
      ;;
    remember)
      case "$PRIORITY" in
        critical) CONFIDENCE="0.85" ;;
        high) CONFIDENCE="0.80" ;;
        medium) CONFIDENCE="0.70" ;;
      esac
      ;;
    success_pattern) CONFIDENCE="0.80" ;;
    preference) CONFIDENCE="0.75" ;;
  esac
fi

# 创建目录结构
mkdir -p "$LEARNING_DIR/learnings"

# 生成唯一ID
RANDOM_HEX=$(openssl rand -hex 3 2>/dev/null || echo "$(date +%s)")
LEARNING_ID="learning_$(date +%s)_${RANDOM_HEX}"

# 查找下一个序号
COUNTER=1
while [[ -f "$LEARNING_DIR/learnings/${DATE_PREFIX}_$(printf "%03d" $COUNTER).json" ]]; do
  COUNTER=$((COUNTER + 1))
done
FILENAME="${DATE_PREFIX}_$(printf "%03d" $COUNTER).json"

# 转换标签为JSON数组
if [[ -n "$TAGS" ]]; then
  TAG_ARRAY=$(echo "$TAGS" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')
  TAG_JSON="[$TAG_ARRAY]"
else
  TAG_JSON="[]"
fi

# 创建学习记录JSON（用jq确保内容安全转义）
jq -n \
  --arg id "$LEARNING_ID" \
  --arg type "$TYPE" \
  --arg content "$CONTENT" \
  --arg context "$CONTEXT" \
  --argjson confidence "$CONFIDENCE" \
  --arg priority "$PRIORITY" \
  --argjson tags "$TAG_JSON" \
  --arg lastVerified "$TIMESTAMP" \
  --arg createdAt "$TIMESTAMP" \
  --arg source "$SOURCE" \
  '{
    id: $id,
    type: $type,
    content: $content,
    context: $context,
    confidence: $confidence,
    priority: $priority,
    tags: $tags,
    usageCount: 0,
    lastVerified: $lastVerified,
    createdAt: $createdAt,
    source: $source
  }' > "$LEARNING_DIR/learnings/$FILENAME"

# 更新索引
bash "$SCRIPT_DIR/rebuild_index.sh" >/dev/null 2>&1 || true

# 更新摘要
bash "$SCRIPT_DIR/update_summary.sh" >/dev/null 2>&1 || true

echo "✅ 学习记录已添加: $FILENAME"
echo "   ID: $LEARNING_ID"
echo "   类型: $TYPE"
echo "   优先级: $PRIORITY"
echo "   置信度: $CONFIDENCE"
