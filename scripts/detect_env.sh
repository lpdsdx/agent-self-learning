#!/usr/bin/env bash
set -euo pipefail

# AI IDE 环境检测脚本
# 自动检测当前运行的 AI IDE 环境并返回相应的配置

detect_ide() {
  # 按优先级检测环境变量
  if [[ -n "${GEMINI_PLUGIN_ROOT:-}" ]]; then
    echo "gemini"
    return 0
  elif [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
    echo "claude"
    return 0
  elif [[ -n "${CODEX_PLUGIN_ROOT:-}" ]]; then
    echo "codex"
    return 0
  elif [[ -n "${CURSOR_PLUGIN_ROOT:-}" ]]; then
    echo "cursor"
    return 0
  elif [[ -n "${WINDSURF_PLUGIN_ROOT:-}" ]]; then
    echo "windsurf"
    return 0
  elif [[ -n "${CLINE_PLUGIN_ROOT:-}" ]]; then
    echo "cline"
    return 0
  fi
  
  # 检测标准路径
  if [[ -d "$HOME/.gemini/antigravity/skills" ]]; then
    echo "gemini"
  elif [[ -d "$HOME/.claude/skills" ]]; then
    echo "claude"
  elif [[ -d "$HOME/.codex/skills" ]]; then
    echo "codex"
  elif [[ -d "$HOME/.cursor/extensions" ]]; then
    echo "cursor"
  elif [[ -d "$HOME/.windsurf/plugins" ]]; then
    echo "windsurf"
  elif [[ -d "$HOME/.cline/skills" ]]; then
    echo "cline"
  else
    echo "unknown"
  fi
}

get_plugin_root() {
  local ide="$1"
  
  case "$ide" in
    gemini)
      echo "${GEMINI_PLUGIN_ROOT:-$HOME/.gemini/antigravity/skills/agent-self-learning}"
      ;;
    claude)
      echo "${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/skills/agent-self-learning}"
      ;;
    codex)
      echo "${CODEX_PLUGIN_ROOT:-$HOME/.codex/skills/agent-self-learning}"
      ;;
    cursor)
      echo "${CURSOR_PLUGIN_ROOT:-$HOME/.cursor/extensions/agent-self-learning}"
      ;;
    windsurf)
      echo "${WINDSURF_PLUGIN_ROOT:-$HOME/.windsurf/plugins/agent-self-learning}"
      ;;
    cline)
      echo "${CLINE_PLUGIN_ROOT:-$HOME/.cline/skills/agent-self-learning}"
      ;;
    *)
      # 回退到当前脚本所在目录的父目录
      echo "$(cd "$(dirname "$0")/.." && pwd)"
      ;;
  esac
}

get_learning_dir() {
  local ide="$1"

  # 优先使用环境变量
  if [[ -n "${LEARNING_DIR:-}" ]]; then
    echo "$LEARNING_DIR"
    return 0
  fi

  # 根据 IDE 返回默认路径（项目级相对路径）
  case "$ide" in
    cursor|windsurf)
      echo ".ai-learnings"
      ;;
    *)
      echo ".learnings"
      ;;
  esac
}

# 主函数
main() {
  local action="${1:-detect}"
  
  case "$action" in
    detect)
      detect_ide
      ;;
    plugin-root)
      local ide=$(detect_ide)
      get_plugin_root "$ide"
      ;;
    learning-dir)
      local ide=$(detect_ide)
      get_learning_dir "$ide"
      ;;
    info)
      local ide=$(detect_ide)
      echo "IDE: $ide"
      echo "Plugin Root: $(get_plugin_root "$ide")"
      echo "Learning Dir: $(get_learning_dir "$ide")"
      ;;
    *)
      echo "用法: detect_env.sh [detect|plugin-root|learning-dir|info]"
      exit 1
      ;;
  esac
}

main "$@"
