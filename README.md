# Agent Self-Learning

A lightweight, cross-IDE self-learning system for AI coding agents. Automatically captures corrections, preferences, success patterns, and explicit memories from user interactions, building a persistent knowledge base that evolves across sessions.

**Supported AI IDEs**: Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, Cline (Roo Code)

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

## Requirements

- Bash 3.2+ (macOS compatible)
- `jq` (JSON processor)
- `bc` (for confidence calculations)

## Credits

Inspired by [gyc567/open-reflect](https://github.com/gyc567/open-reflect).

## License

MIT

## Contributing

Issues and PRs welcome!
