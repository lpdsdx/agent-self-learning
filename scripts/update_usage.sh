#!/usr/bin/env bash
set -euo pipefail

# 更新学习记录的使用计数和验证时间（多 IDE 兼容，跨平台）
# 用法: update_usage.sh --id <learning_id>
# 当智能体实际应用某条学习记录时调用，usageCount +1 并刷新 lastVerified

# 依赖检查
if ! command -v jq &>/dev/null; then
  echo "错误: 需要 jq，请先安装" >&2
  exit 1
fi

# 环境检测
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/detect_env.sh" ]]; then
  LEARNING_DIR="${LEARNING_DIR:-$(bash "$SCRIPT_DIR/detect_env.sh" learning-dir)}"
else
  LEARNING_DIR="${LEARNING_DIR:-.learnings}"
fi

# 解析参数
LEARNING_ID=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --id) LEARNING_ID="$2"; shift 2 ;;
    *)
      echo "未知参数: $1"
      exit 1
      ;;
  esac
done

# 验证必需参数
if [[ -z "$LEARNING_ID" ]]; then
  echo "错误: --id 是必需参数"
  echo "用法: update_usage.sh --id <learning_id>"
  exit 1
fi

if [[ ! -d "$LEARNING_DIR/learnings" ]]; then
  echo "未找到学习记录"
  exit 1
fi

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S%z")

# 按 ID 查找对应记录文件
TARGET=""
for file in "$LEARNING_DIR/learnings"/*.json; do
  [[ -f "$file" ]] || continue
  if [[ "$(jq -r '.id' "$file")" == "$LEARNING_ID" ]]; then
    TARGET="$file"
    break
  fi
done

if [[ -z "$TARGET" ]]; then
  echo "错误: 未找到 ID 为 '$LEARNING_ID' 的学习记录"
  exit 1
fi

# 原子更新: usageCount +1, 刷新 lastVerified
OLD_COUNT=$(jq -r '.usageCount // 0' "$TARGET")
jq --arg ts "$TIMESTAMP" \
   '.usageCount = ((.usageCount // 0) + 1) | .lastVerified = $ts' \
   "$TARGET" > "$TARGET.tmp" && mv "$TARGET.tmp" "$TARGET"
NEW_COUNT=$(jq -r '.usageCount' "$TARGET")

# 更新索引
bash "$SCRIPT_DIR/rebuild_index.sh" >/dev/null 2>&1 || true

echo "✅ 已更新使用计数: $(basename "$TARGET")"
echo "   ID: $LEARNING_ID"
echo "   usageCount: $OLD_COUNT -> $NEW_COUNT"
echo "   lastVerified: $TIMESTAMP"
