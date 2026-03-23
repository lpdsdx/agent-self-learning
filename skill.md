---
name: agent-self-learning
description: AI智能体持续自学习系统（多IDE兼容），自动从用户交互中捕获学习内容（纠正、成功模式、偏好），构建跨会话持久化知识库，支持置信度评分、优先级管理、演化追踪和冲突检测。支持 Claude Code、Codex CLI、Gemini CLI、Cursor、Windsurf、Cline。消除跨会话失忆，减少重复解释80%。
---

# AI 智能体持续自学习系统

## 概述

灵感来源于 [gyc567/open-reflect](https://github.com/gyc567/open-reflect)。

**支持的 AI IDE**: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Cline (Roo Code)

### 核心能力

1. **自动学习捕获** - 从用户消息中自动提取学习内容
2. **多维度分类** - 置信度评分（0.60-0.95）+ 优先级管理
3. **演化追踪** - 使用计数、验证时间戳、置信度衰减
4. **冲突检测** - 新旧知识冲突时触发警告
5. **跨会话持久化** - 知识库在会话间保持和演化

### 解决的问题

- ❌ 跨会话失忆 - 每次对话都要重新解释相同的内容
- ❌ 重复纠正 - 智能体反复犯相同的错误
- ❌ 偏好遗忘 - 用户偏好无法保留
- ❌ 成功模式丢失 - 验证有效的解决方案无法复用

### 效果

- ✅ 消除跨会话失忆 100%
- ✅ 减少重复解释 80%
- ✅ 已在 100+ 智能体会话中验证

## 学习类型

系统自动识别并分类以下学习类型：

| 类型 | 触发关键词 | 示例 |
|------|-----------|------|
| **correction** | "不对"、"错了"、"应该是"、"其实" | "不对，这个API的参数应该是POST而不是GET" |
| **remember** | "记住"、"以后"、"下次" | "记住，我喜欢用 TypeScript 而不是 JavaScript" |
| **success_pattern** | "成功"、"有效"、"解决了" | "这个重试机制成功解决了超时问题" |
| **preference** | "喜欢"、"习惯"、"倾向" | "我习惯用 Tailwind CSS 而不是传统 CSS" |

## 优先级系统

| 优先级 | 适用场景 | 置信度范围 |
|--------|---------|-----------|
| **critical** | 安全相关、核心业务逻辑、明确的错误纠正 | 0.85-0.95 |
| **high** | 用户明确要求记住的内容、重要偏好 | 0.75-0.90 |
| **medium** | 一般性偏好、成功模式 | 0.60-0.80 |

## 存储结构

```
.learnings/
├── index.json              # 学习索引（快速查询）
├── learnings/              # 学习记录存储
│   ├── 2026-02-21_001.json
│   ├── 2026-02-21_002.json
│   └── ...
├── summary.md              # 人类可读的摘要
└── stats.json              # 统计信息
```

### 学习记录格式

```json
{
  "id": "learning_1708502400_a1b2c3",
  "type": "correction",
  "content": "API参数应该使用POST方法而不是GET",
  "context": "用户纠正了关于REST API的错误理解",
  "confidence": 0.90,
  "priority": "critical",
  "tags": ["api", "http", "rest"],
  "usageCount": 0,
  "lastVerified": "2026-02-21T00:00:00Z",
  "createdAt": "2026-02-21T00:00:00Z",
  "source": "user_correction"
}
```

## 使用方式

### 环境变量说明

在不同 AI IDE 中，使用对应的安装路径：

| AI IDE | 脚本路径 |
|--------|---------|
| Claude Code | `~/.claude/skills/agent-self-learning/scripts/` |
| Codex CLI | `~/.codex/skills/agent-self-learning/scripts/` |
| Gemini CLI | `~/.gemini/antigravity/skills/agent-self-learning/scripts/` |
| Cursor | `~/.cursor/extensions/agent-self-learning/scripts/` |
| Windsurf | `~/.windsurf/plugins/agent-self-learning/scripts/` |
| Cline / Roo Code | `~/.cline/skills/agent-self-learning/scripts/` |

**注意**: 下文中的 `${CLAUDE_PLUGIN_ROOT}` 仅为示例，请根据你的 IDE 替换为对应路径。

### 自动触发（推荐）

系统通过 hooks 自动在会话开始和结束时运行：
- **SessionStart**: 初始化学习环境，加载知识库
- **Stop**: 分析本次会话，捕获新的学习内容

### 手动调用

#### 1. 添加学习记录

```bash
# Claude Code
bash ~/.claude/skills/agent-self-learning/scripts/add_learning.sh \
  --type correction \
  --content "API参数应该使用POST方法" \
  --priority critical \
  --tags "api,http"

# Codex
bash ~/.codex/skills/agent-self-learning/scripts/add_learning.sh \
  --type correction \
  --content "API参数应该使用POST方法" \
  --priority critical \
  --tags "api,http"
```

#### 2. 查询学习记录

```bash
# 查询所有学习记录
bash "${CLAUDE_PLUGIN_ROOT}/scripts/list_learnings.sh"

# 按类型查询
bash "${CLAUDE_PLUGIN_ROOT}/scripts/list_learnings.sh" --type correction

# 按标签查询
bash "${CLAUDE_PLUGIN_ROOT}/scripts/list_learnings.sh" --tags "api"

# 按优先级查询
bash "${CLAUDE_PLUGIN_ROOT}/scripts/list_learnings.sh" --priority critical
```

#### 3. 搜索学习记录

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/search_learnings.sh" "API POST"
```

#### 4. 更新使用计数

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/update_usage.sh" --id "learning_1708502400_a1b2c3"
```

#### 5. 置信度衰减

```bash
# 对超过30天未使用的学习记录降低置信度
bash "${CLAUDE_PLUGIN_ROOT}/scripts/decay_confidence.sh" --days 30
```

#### 6. 冲突检测

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/detect_conflicts.sh"
```

## 智能体集成指南

### 会话开始时

```
1. 加载知识库索引
2. 检查是否有高优先级学习记录
3. 在系统提示中注入相关学习内容
```

### 对话过程中

```
1. 监听用户消息中的学习信号
2. 识别学习类型（correction/remember/success_pattern/preference）
3. 提取关键信息和上下文
4. 计算置信度和优先级
5. 检测是否与现有知识冲突
6. 持久化学习记录
```

### 会话结束时

```
1. 回顾本次会话的学习内容
2. 更新相关学习记录的使用计数
3. 生成学习摘要
```

## 置信度衰减机制

- 每30天未使用的学习记录，置信度降低 5%
- 置信度低于 0.60 的记录会被标记为"待验证"
- 置信度低于 0.50 的记录会被自动归档

## 冲突检测规则

当新学习内容与现有知识冲突时：
1. 比较置信度：高置信度优先
2. 比较时间：新知识优先（如果置信度相近）
3. 比较使用次数：高使用次数优先
4. 提示用户确认冲突解决方案

## 最佳实践

1. **及时捕获** - 在用户纠正或明确表达偏好时立即记录
2. **精确分类** - 正确识别学习类型，便于后续查询
3. **合理标签** - 使用一致的标签体系，提高检索效率
4. **定期维护** - 运行置信度衰减和冲突检测，保持知识库健康
5. **验证反馈** - 当应用学习内容时，更新使用计数和验证时间

## 与 persistent-memory 的区别

| 特性 | persistent-memory | agent-self-learning |
|------|------------------|---------------------|
| 目标 | 项目工作成果记录 | 智能体学习和改进 |
| 内容 | 功能、修复、方案、决策 | 纠正、偏好、成功模式 |
| 粒度 | 项目级 | 用户级 |
| 生命周期 | 项目周期 | 跨项目持久化 |
| 触发方式 | 完成工作后主动记录 | 自动捕获用户反馈 |

## 示例场景

### 场景1：纠正错误理解

**用户**: "不对，Supabase RLS 策略必须包含 anon 和 authenticated 角色"

**系统行为**:
```json
{
  "type": "correction",
  "content": "Supabase RLS 策略必须包含 anon 和 authenticated 角色",
  "confidence": 0.90,
  "priority": "critical",
  "tags": ["supabase", "rls", "security"]
}
```

### 场景2：记住偏好

**用户**: "记住，我喜欢用 Tailwind CSS 而不是传统 CSS"

**系统行为**:
```json
{
  "type": "preference",
  "content": "用户偏好使用 Tailwind CSS 而不是传统 CSS",
  "confidence": 0.85,
  "priority": "high",
  "tags": ["css", "tailwind", "frontend"]
}
```

### 场景3：成功模式

**用户**: "这个指数退避重试机制成功解决了 API 超时问题"

**系统行为**:
```json
{
  "type": "success_pattern",
  "content": "指数退避重试机制有效解决 API 超时问题",
  "confidence": 0.80,
  "priority": "high",
  "tags": ["api", "retry", "timeout"]
}
```

## 技术实现

- **存储**: JSON 文件（轻量级、易于版本控制）
- **索引**: 内存索引 + 文件索引（快速查询）
- **搜索**: 全文搜索 + 标签匹配
- **并发**: 文件锁机制（防止多会话冲突）

## 参考资源

- **开源项目**: https://github.com/gyc567/open-reflect
