<p align="center">
  <img src="https://img.shields.io/badge/AI_Agent-Self_Learning-blueviolet?style=for-the-badge&logo=brain&logoColor=white" alt="Agent Self-Learning" />
</p>

<h1 align="center">Agent Self-Learning</h1>

<p align="center">
  <strong>轻量级、跨 IDE 的 AI 编程智能体自学习系统。</strong><br/>
  自动从用户交互中捕获纠正、偏好、成功模式，<br/>
  构建跨会话持久化的知识库。
</p>

<p align="center">
  <a href="../LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License MIT" /></a>
  <img src="https://img.shields.io/badge/Bash-3.2%2B-4EAA25?logo=gnubash&logoColor=white" alt="Bash 3.2+" />
  <img src="https://img.shields.io/badge/macOS-compatible-000000?logo=apple&logoColor=white" alt="macOS compatible" />
  <img src="https://img.shields.io/badge/Linux-compatible-FCC624?logo=linux&logoColor=black" alt="Linux compatible" />
  <img src="https://img.shields.io/badge/Windows-Git_Bash%20%7C%20WSL-0078D6?logo=windows&logoColor=white" alt="Windows compatible" />
</p>

<p align="center">
  <a href="../README.md">English</a> | <b>中文</b>
</p>

<p align="center">
  <code>Claude Code</code> · <code>Codex CLI</code> · <code>Gemini CLI</code> · <code>Cursor</code> · <code>Windsurf</code> · <code>Cline / Roo Code</code>
</p>

---

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

## 真实使用场景

> 以下数据来自 3 个项目的实际使用，数周日常开发中累积了 180+ 条学习记录。

### 典型工作流

最常见的使用模式是**任务结束后批量记录** - 完成一个功能、调试会话或部署后，你对智能体说:

> *"用 agent-self-learning skill 记录下上述所有过程关键信息、知识、经验、方法、待办。"*

智能体会一次性提取并持久化多条学习记录:

```bash
# 智能体自动执行多次 add_learning.sh:

# 1. 架构决策
bash scripts/add_learning.sh --type remember --priority critical \
  --content "所有设计必须遵循'独立社会系统 + adapter'模式，不能内嵌到核心" \
  --tags "architecture,design-principle"

# 2. 部署信息
bash scripts/add_learning.sh --type remember --priority critical \
  --content "服务器: SSH 端口 22，仅 Key 认证，Docker 部署" \
  --tags "deployment,infrastructure"

# 3. 有效方案
bash scripts/add_learning.sh --type success_pattern --priority high \
  --content "将外部 CDN 资源本地化到 public/ 目录是解决加载慢的最高性价比方案" \
  --tags "performance,cdn,optimization"

# 4. 踩坑经验
bash scripts/add_learning.sh --type correction --priority critical \
  --content "Vercel 环境变量通过 echo 管道传入会带尾部换行导致 API 调用失败，必须用 printf '%s' 代替" \
  --tags "vercel,env,debugging"
```

### 会话开始时加载知识

新会话开始时，加载之前的学习记录恢复上下文:

> *"用 agent-self-learning skill 加载学习记录。"*

```bash
bash scripts/list_learnings.sh
# 输出: 127 条记录已加载，21 条 critical，92 条 high
# 智能体现在拥有之前所有会话的完整上下文
```

### 来自生产环境的真实案例

**纠正** - 捕获微妙的 API bug:

> *"不对，查询可能返回 0 行时应该用 `.maybeSingle()` 而不是 `.single()`"*

```json
{ "type": "correction", "content": "Supabase 查询可能返回 0 行时应使用 .maybeSingle() 而不是 .single()，否则会抛出 406 错误", "priority": "critical", "tags": ["supabase", "database"] }
```

**成功模式** - Docker 网络踩坑:

> *"API 代理容器重启后总是掉出网络"*

```json
{ "type": "success_pattern", "content": "Docker 容器重启会丢失网络成员关系，必须在 docker-compose.yml 中显式声明 networks", "priority": "high", "tags": ["docker", "networking"] }
```

**记忆** - 保留项目路由知识:

> *"记录下渠道路由策略: 数字越大优先级越高，优先级相同按权重随机，失败自动降级到低优先级"*

```json
{ "type": "remember", "content": "渠道路由: 优先级(数字越大越优先)，权重(优先级相同时加权随机，都为0则均分)，故障自动降级到低优先级渠道", "priority": "high", "tags": ["routing", "architecture"] }
```

### 累积知识统计（真实数据）

| 项目 | 记录数 | 纠正 | 偏好 | 成功模式 | 记忆 |
|------|--------|------|------|---------|------|
| API 网关 | 127 | 10 | 5 | 72 | 40 |
| 社交平台 | 43 | 5 | 4 | 15 | 19 |
| 数据分析面板 | 10 | 1 | 1 | 5 | 3 |
| **合计** | **180** | **16** | **10** | **92** | **62** |

成功模式占比最高，因为系统会持续捕获在你的代码库中真正有效的方案。

### 当前局限性

- **关键词自动触发**: 理想模式是从对话中自动检测学习信号。实际使用中，大多数用户仍然手动触发记录（如"记录下这次会话的学习内容"）。提升自动检测准确率是持续改进方向。
- **IDE 钩子**: 会话生命周期钩子（SessionStart/Stop）依赖各 IDE 的扩展 API。并非所有 IDE 都同等支持钩子 - Claude Code 的钩子在某些配置下可能无法可靠触发。手动调用仍然是可靠的兜底方案。

## IDE 集成配置

在你的 IDE 系统提示词文件中添加以下指令，让智能体自动使用该 skill。

### 各 IDE 指令文件对照

| IDE / CLI | 项目级文件 | 用户级文件 |
|-----------|-----------|-----------|
| Claude Code | `CLAUDE.md` | `~/.claude/CLAUDE.md` |
| Codex CLI | `AGENTS.md` | `~/.codex/AGENTS.md` |
| Gemini CLI | `GEMINI.md` | `~/.gemini/GEMINI.md` |
| Cursor | `.cursor/rules/*.mdc` | 设置 > Rules for AI |
| Windsurf | `.windsurf/rules/*.md` | 设置 > Global Rules |
| Cline | `.clinerules/*.md` | `~/Documents/Cline/Rules/` |
| Roo Code | `.roo/rules/*.md` | `~/.roo/rules/` |

### 配置示例 (Claude Code `CLAUDE.md`)

其他 IDE 同理，只需将脚本路径替换为上表中对应 IDE 的安装路径即可。

```markdown
## Self-Learning

- 会话开始时: 执行 `bash ~/.claude/skills/agent-self-learning/scripts/list_learnings.sh` 加载历史知识
- 会话结束时: 扫描对话中的学习信号（纠正、偏好、成功模式、需要记住的内容），通过 `bash ~/.claude/skills/agent-self-learning/scripts/add_learning.sh` 记录
- 自动检测用户消息中的学习信号:
  - "不对"、"错了"、"应该是" -> correction (critical, 0.90)
  - "记住"、"以后"、"下次" -> remember (high, 0.80)
  - "成功"、"有效"、"解决了" -> success_pattern (high, 0.80)
  - "喜欢"、"习惯"、"倾向" -> preference (high, 0.75)
```

## 系统要求

- Bash 3.2+（macOS / Linux / Windows Git Bash 或 WSL）
- `jq`（JSON 处理器）
- `python3`（可选，部分平台日期解析回退用）

## 致谢

- 基于 EvoMap 方案2 设计方法论
- 灵感来源于 [gyc567/open-reflect](https://github.com/gyc567/open-reflect)

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request!
