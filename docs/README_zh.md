# Agent Self-Learning (中文文档)

[English](../README.md) | 中文

轻量级、跨 IDE 的 AI 编程智能体自学习系统。自动从用户交互中捕获纠正、偏好、成功模式和显式记忆，构建跨会话持久化的知识库。

**支持的 AI IDE**: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Cline (Roo Code)

## 为什么需要

AI 编程智能体每次会话都从零开始。你反复纠正同样的错误、重复解释同样的偏好、丢失已验证的解决方案。这个 skill 解决这些问题:

- 消除跨会话失忆
- 减少重复解释约 80%
- 保留已验证的解决方案供复用
- 已在 100+ 智能体会话中验证

## 快速开始

### 安装

**自动安装（推荐）:**

```bash
git clone https://github.com/lpdsdx/agent-self-learning.git
cd agent-self-learning
bash install.sh
```

安装脚本会自动检测你的 IDE 并将文件复制到正确位置。

**手动安装** - 将文件复制到对应 IDE 的 skill 目录:

| AI IDE | 安装路径 |
|--------|---------|
| Claude Code | `~/.claude/skills/agent-self-learning/` |
| Codex CLI | `~/.codex/skills/agent-self-learning/` |
| Gemini CLI | `~/.gemini/antigravity/skills/agent-self-learning/` |
| Cursor | `~/.cursor/extensions/agent-self-learning/` |
| Windsurf | `~/.windsurf/plugins/agent-self-learning/` |
| Cline / Roo Code | `~/.cline/skills/agent-self-learning/` |

### 工作原理

系统挂接到 AI IDE 的会话生命周期:

```
会话开始 ──> 加载知识库，展示高优先级学习记录
    |
会话过程 ──> 监听学习信号，分类并持久化
    |
会话结束 ──> 回顾会话，更新使用计数，生成摘要
```

### 使用方式

```bash
# 添加学习记录
bash scripts/add_learning.sh \
  --type correction \
  --content "这个 API 应该用 POST 而不是 GET" \
  --priority critical \
  --tags "api,http"

# 列出所有学习记录
bash scripts/list_learnings.sh

# 按类型 / 优先级 / 标签过滤
bash scripts/list_learnings.sh --type correction
bash scripts/list_learnings.sh --priority critical
bash scripts/list_learnings.sh --tags "api"

# 关键词搜索
bash scripts/search_learnings.sh "API 超时"

# 置信度衰减（超过 30 天未使用）
bash scripts/decay_confidence.sh 30

# 冲突检测
bash scripts/detect_conflicts.sh

# 重建索引（索引损坏时）
bash scripts/rebuild_index.sh
```

## 学习类型

| 类型 | 触发关键词 | 示例 |
|------|-----------|------|
| `correction` | "不对"、"错了"、"应该是" | "不对，这个 API 应该用 POST 而不是 GET" |
| `remember` | "记住"、"以后"、"下次" | "记住，我喜欢用 TypeScript" |
| `success_pattern` | "成功"、"有效"、"解决了" | "指数退避重试机制解决了超时问题" |
| `preference` | "喜欢"、"习惯"、"倾向" | "我习惯用 Tailwind CSS" |

## 优先级与置信度

| 优先级 | 适用场景 | 置信度范围 |
|--------|---------|-----------|
| `critical` | 安全相关、核心逻辑、明确纠正 | 0.85 - 0.95 |
| `high` | 明确要求记住的内容、重要偏好 | 0.75 - 0.90 |
| `medium` | 一般偏好、成功模式 | 0.60 - 0.80 |

**置信度衰减**: 超过 30 天未使用的记录置信度降低 5%。低于 0.60 标记为"待验证"，低于 0.50 自动归档。

**冲突检测**: 新知识与现有记录冲突时，系统比较置信度、时间和使用次数，提示人工审查。

## 存储结构

```
.learnings/
├── index.json          # 快速查询索引
├── learnings/          # 单条 JSON 记录
│   ├── 2026-01-15_001.json
│   └── ...
├── summary.md          # 人类可读摘要
└── stats.json          # 统计信息
```

## 环境变量

| 变量 | 说明 | 默认值 |
|------|-----|--------|
| `LEARNING_DIR` | 自定义存储路径 | `.learnings`（Cursor/Windsurf 为 `.ai-learnings`） |
| `TZ` | 时间戳时区 | 系统默认 |
| `*_PLUGIN_ROOT` | IDE 专属插件根目录 | 自动检测 |

## 脚本说明

| 脚本 | 功能 |
|------|-----|
| `add_learning.sh` | 添加学习记录 |
| `list_learnings.sh` | 列出/过滤学习记录 |
| `search_learnings.sh` | 全文关键词搜索 |
| `decay_confidence.sh` | 对过期记录执行置信度衰减 |
| `detect_conflicts.sh` | 检测知识冲突 |
| `rebuild_index.sh` | 从原始记录重建索引 |
| `update_summary.sh` | 重新生成摘要 |
| `detect_env.sh` | 自动检测 IDE 环境 |
| `session_start.sh` | 会话初始化钩子 |
| `session_end.sh` | 会话结束钩子 |

## 系统要求

- Bash 3.2+（兼容 macOS）
- `jq`（JSON 处理器）
- `bc`（置信度计算）

## 致谢

灵感来源于 [gyc567/open-reflect](https://github.com/gyc567/open-reflect)。

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request!
