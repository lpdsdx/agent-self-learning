#!/usr/bin/env bash
set -euo pipefail

# AI 智能体自学习系统 - 多 IDE 安装脚本
# 支持: Gemini, Claude Code, Codex, Cursor, Windsurf, Cline

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "AI 智能体自学习系统 - 安装向导"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检测当前环境
detect_ide() {
  if [[ -n "${GEMINI_PLUGIN_ROOT:-}" ]] || [[ -d "$HOME/.gemini/antigravity/skills" ]]; then
    echo "gemini"
  elif [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]] || [[ -d "$HOME/.claude/skills" ]]; then
    echo "claude"
  elif [[ -n "${CODEX_PLUGIN_ROOT:-}" ]] || [[ -d "$HOME/.codex/skills" ]]; then
    echo "codex"
  elif [[ -n "${CURSOR_PLUGIN_ROOT:-}" ]] || [[ -d "$HOME/.cursor/extensions" ]]; then
    echo "cursor"
  elif [[ -n "${WINDSURF_PLUGIN_ROOT:-}" ]] || [[ -d "$HOME/.windsurf/plugins" ]]; then
    echo "windsurf"
  elif [[ -n "${CLINE_PLUGIN_ROOT:-}" ]] || [[ -d "$HOME/.cline/skills" ]]; then
    echo "cline"
  else
    echo "unknown"
  fi
}

get_install_path() {
  local ide="$1"
  case "$ide" in
    gemini) echo "$HOME/.gemini/antigravity/skills/agent-self-learning" ;;
    claude) echo "$HOME/.claude/skills/agent-self-learning" ;;
    codex) echo "$HOME/.codex/skills/agent-self-learning" ;;
    cursor) echo "$HOME/.cursor/extensions/agent-self-learning" ;;
    windsurf) echo "$HOME/.windsurf/plugins/agent-self-learning" ;;
    cline) echo "$HOME/.cline/skills/agent-self-learning" ;;
    *) echo "$HOME/.ai-skills/agent-self-learning" ;;
  esac
}

# 主安装流程
main() {
  local ide=$(detect_ide)
  local install_path=$(get_install_path "$ide")

  echo "检测到的 IDE: $ide"
  echo "安装路径: $install_path"
  echo ""

  # 询问用户确认
  read -p "是否继续安装? (y/n) " -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "安装已取消"
    exit 0
  fi

  # 创建目录
  mkdir -p "$install_path/scripts"
  mkdir -p "$install_path/references"

  # 复制文件
  if [[ -d "$(dirname "$0")" ]]; then
    cp -r "$(dirname "$0")"/* "$install_path/"
    echo "✅ 文件已复制"
  fi

  # 设置权限
  chmod +x "$install_path"/scripts/*.sh
  echo "✅ 权限已设置"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "安装完成！"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "快速开始:"
  echo "  bash $install_path/scripts/add_learning.sh \\"
  echo "    --type correction \\"
  echo "    --content \"学习内容\" \\"
  echo "    --priority critical"
  echo ""
  echo "查看文档: cat $install_path/README.md"
}

main "$@"
