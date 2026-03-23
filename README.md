<p align="center">
  <img src="https://img.shields.io/badge/AI_Agent-Self_Learning-blueviolet?style=for-the-badge&logo=brain&logoColor=white" alt="Agent Self-Learning" />
</p>

<h1 align="center">Agent Self-Learning</h1>

<p align="center">
  <strong>A lightweight, cross-IDE self-learning system for AI coding agents.</strong><br/>
  Automatically captures corrections, preferences, success patterns from user interactions,<br/>
  building a persistent knowledge base that evolves across sessions.
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License MIT" /></a>
  <img src="https://img.shields.io/badge/Bash-3.2%2B-4EAA25?logo=gnubash&logoColor=white" alt="Bash 3.2+" />
  <img src="https://img.shields.io/badge/macOS-compatible-000000?logo=apple&logoColor=white" alt="macOS compatible" />
  <img src="https://img.shields.io/badge/Linux-compatible-FCC624?logo=linux&logoColor=black" alt="Linux compatible" />
  <img src="https://img.shields.io/badge/Windows-Git_Bash%20%7C%20WSL-0078D6?logo=windows&logoColor=white" alt="Windows compatible" />
</p>

<p align="center">
  <b>English</b> | <a href="docs/README_zh.md">中文</a>
</p>

<p align="center">
  <code>Claude Code</code> · <code>Codex CLI</code> · <code>Gemini CLI</code> · <code>Cursor</code> · <code>Windsurf</code> · <code>Cline / Roo Code</code>
</p>

---

## Why

AI coding agents start from zero every session. You correct the same mistakes, re-explain the same preferences, and lose proven solutions. This skill fixes that:

- Eliminates cross-session amnesia
- Reduces repeated explanations by ~80%
- Preserves validated solutions for reuse
- Validated across 100+ agent sessions

## Quick Start

### Install

**Auto install (recommended):**

```bash
git clone https://github.com/lpdsdx/agent-self-learning.git
cd agent-self-learning
bash install.sh
```

The installer auto-detects your IDE and copies files to the correct location.

**Manual install** - copy files to your IDE's skill directory:

| AI IDE | Install Path |
|--------|-------------|
| Claude Code | `~/.claude/skills/agent-self-learning/` |
| Codex CLI | `~/.codex/skills/agent-self-learning/` |
| Gemini CLI | `~/.gemini/antigravity/skills/agent-self-learning/` |
| Cursor | `~/.cursor/extensions/agent-self-learning/` |
| Windsurf | `~/.windsurf/plugins/agent-self-learning/` |
| Cline / Roo Code | `~/.cline/skills/agent-self-learning/` |

### How It Works

The system hooks into your AI IDE's session lifecycle:

```
Session Start ──> Load knowledge base, surface high-priority learnings
       │
During Session ──> Monitor for learning signals, classify & persist
       │
Session End ──> Review session, update usage counts, generate summary
```

### Usage

```bash
# Add a learning
bash scripts/add_learning.sh \
  --type correction \
  --content "Use POST not GET for this API endpoint" \
  --priority critical \
  --tags "api,http"

# List all learnings
bash scripts/list_learnings.sh

# Filter by type / priority / tags
bash scripts/list_learnings.sh --type correction
bash scripts/list_learnings.sh --priority critical
bash scripts/list_learnings.sh --tags "api"

# Search by keyword
bash scripts/search_learnings.sh "API timeout"

# Confidence decay (unused > 30 days)
bash scripts/decay_confidence.sh 30

# Conflict detection
bash scripts/detect_conflicts.sh

# Rebuild index (if corrupted)
bash scripts/rebuild_index.sh
```

## Learning Types

| Type | Trigger Keywords | Example |
|------|-----------------|---------|
| `correction` | "wrong", "should be", "actually" | "This API param should be POST not GET" |
| `remember` | "remember", "from now on", "next time" | "Remember, I prefer TypeScript over JS" |
| `success_pattern` | "worked", "solved", "fixed" | "Exponential backoff fixed the timeout" |
| `preference` | "prefer", "like to", "tend to" | "I prefer Tailwind CSS over vanilla CSS" |

## Priority & Confidence

| Priority | Use Case | Confidence Range |
|----------|---------|-----------------|
| `critical` | Security, core logic, explicit corrections | 0.85 - 0.95 |
| `high` | Explicit requests to remember, key preferences | 0.75 - 0.90 |
| `medium` | General preferences, success patterns | 0.60 - 0.80 |

**Confidence decay**: Records unused for 30+ days lose 5% confidence. Below 0.60 = "needs verification". Below 0.50 = auto-archived.

**Conflict detection**: When new knowledge conflicts with existing records, the system compares confidence, recency, and usage count, then prompts for manual review.

## Storage

```
.learnings/
├── index.json          # Fast lookup index
├── learnings/          # Individual JSON records
│   ├── 2026-01-15_001.json
│   └── ...
├── summary.md          # Human-readable summary
└── stats.json          # Statistics
```

Each record:

```json
{
  "id": "learning_1708502400_a1b2c3",
  "type": "correction",
  "content": "Use POST method for this API endpoint",
  "context": "User corrected REST API misunderstanding",
  "confidence": 0.90,
  "priority": "critical",
  "tags": ["api", "http", "rest"],
  "usageCount": 0,
  "lastVerified": "2026-01-15T00:00:00Z",
  "createdAt": "2026-01-15T00:00:00Z",
  "source": "user_correction"
}
```

## Environment Variables

| Variable | Description | Default |
|----------|------------|---------|
| `LEARNING_DIR` | Override storage path | `.learnings` (`.ai-learnings` for Cursor/Windsurf) |
| `TZ` | Timezone for timestamps | System default |
| `*_PLUGIN_ROOT` | IDE-specific plugin root | Auto-detected |

## Scripts

| Script | Description |
|--------|------------|
| `add_learning.sh` | Add a new learning record |
| `list_learnings.sh` | List/filter learning records |
| `search_learnings.sh` | Full-text keyword search |
| `decay_confidence.sh` | Apply confidence decay to stale records |
| `detect_conflicts.sh` | Find conflicting knowledge entries |
| `rebuild_index.sh` | Rebuild the index from raw records |
| `update_summary.sh` | Regenerate the human-readable summary |
| `detect_env.sh` | Auto-detect IDE environment |
| `session_start.sh` | Session initialization hook |
| `session_end.sh` | Session teardown hook |

## Real-World Usage

> From actual usage across 3 projects, 180+ learning records accumulated over weeks of daily development.

### Typical Workflow

The most common usage pattern is **batch recording at the end of a task** - after completing a feature, debugging session, or deployment, you tell the agent:

> *"Use agent-self-learning to record all key information, knowledge, experience, methods, and TODOs from this session."*

The agent then extracts and persists multiple learnings at once:

```bash
# The agent runs multiple add_learning.sh calls automatically:

# 1. Architecture decision
bash scripts/add_learning.sh --type remember --priority critical \
  --content "All designs must follow 'independent social system + adapter' pattern, never embed into core" \
  --tags "architecture,design-principle"

# 2. Deployment info
bash scripts/add_learning.sh --type remember --priority critical \
  --content "Server: SSH port 22, key-only auth, Docker deployed" \
  --tags "deployment,infrastructure"

# 3. What worked
bash scripts/add_learning.sh --type success_pattern --priority high \
  --content "Localizing external CDN resources to public/ directory is the best cost-effective solution for slow loading" \
  --tags "performance,cdn,optimization"

# 4. Bug fix learned
bash scripts/add_learning.sh --type correction --priority critical \
  --content "Vercel env vars piped via echo carry trailing newline causing API failures - use printf '%s' instead" \
  --tags "vercel,env,debugging"
```

### Loading Knowledge at Session Start

At the beginning of a new session, load previous learnings to restore context:

> *"Use agent-self-learning to load learning records."*

```bash
bash scripts/list_learnings.sh
# Output: 127 records loaded, 21 critical, 92 high priority
# Agent now has full context from previous sessions
```

### Real Examples from Production Use

**Correction** - Catching a subtle API bug:

> *"Wrong - use `.maybeSingle()` not `.single()` when the query might return 0 rows"*

```json
{ "type": "correction", "content": "Supabase queries that may return 0 rows should use .maybeSingle() instead of .single(), otherwise it throws a 406 error", "priority": "critical", "tags": ["supabase", "database"] }
```

**Success Pattern** - Docker networking gotcha:

> *"The API proxy container kept dropping off the network after restart"*

```json
{ "type": "success_pattern", "content": "Docker container restart loses network membership - must declare networks in docker-compose.yml explicitly", "priority": "high", "tags": ["docker", "networking"] }
```

**Remember** - Preserving project routing knowledge:

> *"Record the channel routing strategy: higher number = higher priority, equal priority uses weighted random, failover to lower priority on failure"*

```json
{ "type": "remember", "content": "Channel routing: priority (higher number = higher), weight (random when equal priority, split evenly when all 0), auto-failover to lower priority on failure", "priority": "high", "tags": ["routing", "architecture"] }
```

### Accumulated Knowledge (Real Data)

| Project | Records | Corrections | Preferences | Success Patterns | Remembers |
|---------|---------|-------------|-------------|-----------------|-----------|
| API Gateway | 127 | 10 | 5 | 72 | 40 |
| Social Platform | 43 | 5 | 4 | 15 | 19 |
| Analytics Dashboard | 10 | 1 | 1 | 5 | 3 |
| **Total** | **180** | **16** | **10** | **92** | **62** |

Success patterns dominate because the system naturally captures what actually works in your codebase.

### Current Limitations

- **Keyword auto-trigger**: The ideal mode is automatic detection of learning signals from conversation. In practice, most users still trigger recording manually (e.g., "record this session's learnings"). Improving auto-detection accuracy is an ongoing effort.
- **IDE hooks**: Session lifecycle hooks (SessionStart/Stop) depend on each IDE's extension API. Not all IDEs support hooks equally - Claude Code hooks may not fire reliably in all configurations. Manual invocation remains the reliable fallback.

## IDE Integration

To make the agent use this skill automatically, add instructions to your IDE's system prompt file.

### Instruction File Reference

| IDE / CLI | Project-Level File | User-Level File |
|-----------|-------------------|-----------------|
| Claude Code | `CLAUDE.md` | `~/.claude/CLAUDE.md` |
| Codex CLI | `AGENTS.md` | `~/.codex/AGENTS.md` |
| Gemini CLI | `GEMINI.md` | `~/.gemini/GEMINI.md` |
| Cursor | `.cursor/rules/*.mdc` | Settings > Rules for AI |
| Windsurf | `.windsurf/rules/*.md` | Settings > Global Rules |
| Cline | `.clinerules/*.md` | `~/Documents/Cline/Rules/` |
| Roo Code | `.roo/rules/*.md` | `~/.roo/rules/` |

### Configuration Example (Claude Code `CLAUDE.md`)

Other IDEs follow the same pattern - just replace the script path with your IDE's install path from the table above.

```markdown
## Self-Learning

- On session start: run `bash ~/.claude/skills/agent-self-learning/scripts/list_learnings.sh` to load prior knowledge
- On session end: scan the conversation for learning signals (corrections, preferences, success patterns, things to remember) and record them via `bash ~/.claude/skills/agent-self-learning/scripts/add_learning.sh`
- Auto-detect learning signals from user messages:
  - "wrong", "should be", "actually" -> correction (critical, 0.90)
  - "remember", "from now on", "next time" -> remember (high, 0.80)
  - "worked", "solved", "fixed" -> success_pattern (high, 0.80)
  - "prefer", "like to", "tend to" -> preference (high, 0.75)
```

## Requirements

- Bash 3.2+ (macOS / Linux / Windows via Git Bash or WSL)
- `jq` (JSON processor)
- `python3` (optional, fallback for date parsing on some platforms)

## Credits

Inspired by [gyc567/open-reflect](https://github.com/gyc567/open-reflect).

## License

MIT

## Contributing

Issues and PRs welcome!
