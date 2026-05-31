# Contributing

Thanks for your interest in improving **Agent Self-Learning**. This is a small, focused project and contributions of all sizes are welcome.

## Ways to Contribute

- **Report a bug** — open an issue with steps to reproduce, your OS, and shell version (`bash --version`).
- **Request a feature** — open an issue describing the use case and which AI IDE you use.
- **Add IDE support** — the system is designed to be IDE-agnostic; PRs that wire up a new IDE's install path or session hooks are especially welcome.
- **Improve docs** — fixes to the README (English) or `docs/README_zh.md` (Chinese) are appreciated; keep both in sync where possible.

## Development Setup

The system is plain Bash plus `jq`. No build step.

```bash
git clone https://github.com/lpdsdx/agent-self-learning.git
cd agent-self-learning
# Run any script against an isolated store:
LEARNING_DIR=/tmp/asl-dev/.learnings bash scripts/add_learning.sh \
  --type success_pattern --content "hello world" --priority high --tags "test"
LEARNING_DIR=/tmp/asl-dev/.learnings bash scripts/list_learnings.sh
```

Always set `LEARNING_DIR` to a throwaway path while developing so you don't pollute a real knowledge base.

## Coding Conventions

Match the existing scripts:

- `#!/usr/bin/env bash` + `set -euo pipefail` at the top of every script.
- Check dependencies (`jq`) up front and fail with a clear message.
- Resolve `LEARNING_DIR` via `detect_env.sh` with a `.learnings` fallback.
- Stay cross-platform: macOS (BSD), Linux (GNU), and Windows (Git Bash / WSL). Avoid GNU-only flags; for date math follow the `parse_date` pattern in `decay_confidence.sh`.
- Write JSON with `jq`, never string interpolation. Update records atomically: write to `"$file.tmp"` then `mv`.
- Rebuild the index (`rebuild_index.sh`) after any change to records.

## Before Submitting a PR

- [ ] `bash -n scripts/<changed>.sh` passes (syntax check).
- [ ] Run [shellcheck](https://www.shellcheck.net/) if available and address warnings.
- [ ] Manually exercise the happy path **and** at least one error case against a `LEARNING_DIR` temp store.
- [ ] Update `README.md`, `docs/README_zh.md`, and `CHANGELOG.md` if behavior changed.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
