#!/usr/bin/env bash
set -euo pipefail

# 会话结束提示（跨平台，多 IDE 兼容）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo ""
echo "会话结束提示"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "本次会话中，是否有需要记录的学习内容？"
echo ""
echo "学习类型："
echo "  correction      - 用户纠正了错误理解"
echo "  remember        - 用户要求记住的偏好"
echo "  success_pattern - 验证有效的解决方案"
echo "  preference      - 用户的习惯和倾向"
echo ""
echo "如需添加学习记录，使用："
echo "  bash \"$SCRIPT_DIR/add_learning.sh\" \\"
echo "    --type <type> \\"
echo "    --content \"<内容>\" \\"
echo "    --priority <critical|high|medium> \\"
echo "    --tags \"<标签1>,<标签2>\""
echo ""
